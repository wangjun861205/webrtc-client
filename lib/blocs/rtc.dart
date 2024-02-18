import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_client/apis/rtc_message.dart';
import 'package:webrtc_client/main.dart';
import 'package:webrtc_client/webrtc.dart';

enum RTCStatus {
  initiating,
  calling,
  beingCalled,
  answered,
  canceled,
  refused,
}

class RTC {
  final RTCStatus status;
  Object? error;

  RTC({required this.status, this.error});
}

class RTCCubit extends Cubit<RTC> {
  final String peerID;
  final String peerPhone;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer()..initialize();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer()..initialize();
  late RTCPeerConnection peerConn;
  late StreamSubscription wsSub;

  RTCCubit(
      {required this.peerID,
      required this.peerPhone,
      RTCSessionDescription? remoteDescription})
      : super(RTC(status: RTCStatus.initiating, error: null)) {
    createPeerConnection({
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    }).then((conn) {
      peerConn = conn;
      getUserMedia().then((stream) => localRenderer.srcObject = stream);
      peerConn.onTrack = (event) {
        remoteRenderer.srcObject = event.streams[0];
      };
      peerConn.onIceCandidate = (candidate) {
        sendRTCMessage(
            authToken: AuthToken.token,
            msg: RTCMessage(
                to: peerID,
                typ: "IceCandidate",
                payload: jsonEncode({
                  "id": candidate.sdpMid,
                  "label": candidate.sdpMLineIndex,
                  "candidate": candidate.candidate
                })));
      };
      wsSub = WS.getOrCreateStream(AuthToken.token).listen((event) {
        final json = jsonDecode(event);
        if (json["typ"] != "RTC") {
          return;
        }
        final msg = jsonDecode(json["payload"]);
        switch (msg["typ"]) {
          case "Answer":
            final answer = RTCSessionDescription(msg["sdp"], msg["rtcType"]);
            peerConn
                .setRemoteDescription(answer)
                .then((_) => emit(RTC(status: RTCStatus.answered)));
          case "IceCandidate":
            peerConn.addCandidate(
                RTCIceCandidate(msg["candidate"], msg["id"], msg["label"]));
          case "Refuse":
            emit(RTC(status: RTCStatus.refused));
          case "Cancel":
            emit(RTC(status: RTCStatus.canceled));
        }
      });
      if (remoteDescription != null) {
        peerConn
            .setRemoteDescription(remoteDescription)
            .then((_) => emit(RTC(status: RTCStatus.beingCalled)));
        return;
      }
      peerConn.createOffer().then((description) {
        peerConn.setLocalDescription(description).then((_) {
          try {
            sendRTCMessage(
                authToken: AuthToken.token,
                msg: RTCMessage(
                    to: peerID,
                    typ: "Offer",
                    payload: jsonEncode({
                      "sdp": description.sdp,
                      "rtcType": description.type
                    }))).then((_) {
              emit(RTC(status: RTCStatus.calling));
            }, onError: (err) => emit(RTC(status: state.status, error: err)));
          } catch (err) {
            emit(RTC(status: state.status, error: err));
          }
        });
      });
    });
  }

  @override
  Future<void> close() {
    localRenderer.srcObject?.getTracks().forEach((element) {
      element.stop();
    });
    localRenderer.srcObject = null;
    remoteRenderer.srcObject?.getTracks().forEach((element) {
      element.stop();
    });
    remoteRenderer.srcObject = null;
    peerConn.close();
    wsSub.cancel();
    return super.close();
  }

  void accept() async {
    try {
      final answer = await peerConn.createAnswer();
      await peerConn.setLocalDescription(answer);
      await sendRTCMessage(
          authToken: AuthToken.token,
          msg: RTCMessage(
              to: peerID,
              typ: "Answer",
              payload: jsonEncode({
                "sdp": answer.sdp,
                "rtcType": answer.type,
              })));
      emit(RTC(status: RTCStatus.answered));
    } catch (err) {
      emit(RTC(status: state.status, error: err));
    }
  }

  void refuse() async {
    try {
      await sendRTCMessage(
          authToken: AuthToken.token,
          msg: RTCMessage(to: peerID, typ: "Refuse", payload: ""));
      emit(RTC(status: RTCStatus.refused));
    } catch (err) {
      emit(RTC(status: state.status, error: err));
    }
  }

  void cancel() async {
    try {
      await sendRTCMessage(
          authToken: AuthToken.token,
          msg: RTCMessage(to: peerID, typ: "Cancel", payload: ""));
      emit(RTC(status: RTCStatus.canceled));
    } catch (err) {
      emit(RTC(status: state.status, error: err));
    }
  }
}
