import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_client/main.dart';

enum RTCStatus {
  uninitated,
  initated,
  offering,
  beingCalled,
  answered,
  refused,
  canceled,
  closed,
}

class RTC {
  String? peerID;
  Function()? afterInitated;
  Function()? afterOffering;
  Function()? afterBeingCalled;
  Function()? afterAnswered;
  Function()? afterRefused;
  Function()? afterCanceled;
  Function()? afterClosed;
  RTCStatus status = RTCStatus.uninitated;
  RTCVideoRenderer? localRenderer;
  RTCVideoRenderer? remoteRenderer;
  RTCPeerConnection? peerConnection;
  StreamSubscription? sub;

  RTC({
    this.peerID,
    this.afterInitated,
    this.afterOffering,
    this.afterBeingCalled,
    this.afterAnswered,
    this.afterRefused,
    this.afterCanceled,
    this.afterClosed,
  });

  _initConnection() async {
    peerConnection = await createPeerConnection(
      {
        "iceServers": [
          {"url": "stun:stun.l.google.com:19302"},
        ]
      },
    );
    peerConnection!.onTrack = (event) {
      remoteRenderer!.srcObject = event.streams[0];
    };
    peerConnection!.onIceCandidate = (candidate) {
      WS.getOrCreateSink(AuthToken.token).add(jsonEncode({
            "Message": {
              "to": peerID!,
              "content": jsonEncode({
                "typ": "IceCandidate",
                "calleeId": peerID!,
                "iceCandidate": {
                  "id": candidate.sdpMid,
                  "label": candidate.sdpMLineIndex,
                  "candidate": candidate.candidate,
                }
              })
            }
          }));
    };
  }

  init() async {
    peerConnection?.close();
    localRenderer = RTCVideoRenderer();
    await localRenderer!.initialize();
    remoteRenderer = RTCVideoRenderer();
    await remoteRenderer!.initialize();
    await _initConnection();
    await _mountWSHandlers();
    status = RTCStatus.initated;
    afterInitated?.call();
  }

  _mountWSHandlers() async {
    sub = WS.getOrCreateStream(AuthToken.token).listen((event) async {
      final json = jsonDecode(event);
      if (json["typ"] != "Message") {
        return;
      }
      final content = jsonDecode(json["data"]["content"]);
      switch (content["typ"]) {
        case "Offer":
          debugPrint(event);
          peerID = json["data"]["from"];
          final offer =
              RTCSessionDescription(content["sdp"], content["rtcType"]);
          await peerConnection!.setRemoteDescription(offer);
          status = RTCStatus.beingCalled;
          afterBeingCalled?.call();
        case "Answer":
          final answer =
              RTCSessionDescription(content["sdp"], content["rtcType"]);
          await peerConnection!.setRemoteDescription(answer);
          status = RTCStatus.answered;
          afterAnswered?.call();
        case "Refuse":
          status = RTCStatus.refused;
          afterRefused?.call();
        case "IceCandidate":
          final candidate = content["iceCandidate"]["candidate"];
          final sdpMid = content["iceCandidate"]["id"];
          final sdpMLineIndex = content["iceCandidate"]["label"];
          peerConnection!
              .addCandidate(RTCIceCandidate(candidate, sdpMid, sdpMLineIndex));
        case "Cancel":
          status = RTCStatus.canceled;
          afterCanceled?.call();
        case "Close":
          status = RTCStatus.closed;
          afterClosed?.call();
      }
    });
  }

  _dispose() async {
    localRenderer?.srcObject?.getTracks().forEach((element) {
      element.stop();
    });
    localRenderer?.srcObject = null;
    remoteRenderer?.srcObject?.getTracks().forEach((element) {
      element.stop();
    });
    remoteRenderer?.srcObject = null;
    await sub?.cancel();
    await peerConnection?.close();
  }

  offer() async {
    final localStream = await getUserMedia();
    for (final track in localStream.getVideoTracks()) {
      await peerConnection!.addTrack(track, localStream);
    }
    localRenderer!.srcObject = localStream;
    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    WS.getOrCreateSink(AuthToken.token).add(jsonEncode({
          "Message": {
            "to": peerID,
            "content": jsonEncode(
                {"typ": "Offer", "sdp": offer.sdp, "rtcType": offer.type}),
          }
        }));
    status = RTCStatus.offering;
    afterOffering?.call();
  }

  answer() async {
    final localStream = await getUserMedia();
    for (final track in localStream.getVideoTracks()) {
      await peerConnection!.addTrack(track, localStream);
    }
    localRenderer!.srcObject = localStream;
    final answer = await peerConnection!.createAnswer();
    peerConnection!.setLocalDescription(answer);
    WS.getOrCreateSink(AuthToken.token).add(jsonEncode({
          "Message": {
            "to": peerID,
            "content": jsonEncode({
              "typ": "Answer",
              "sdp": answer.sdp,
              "rtcType": answer.type,
            })
          }
        }));
    status = RTCStatus.answered;
    afterAnswered?.call();
  }

  cancel() async {
    WS.getOrCreateSink(AuthToken.token).add(jsonEncode({
          "Message": {
            "to": peerID,
            "content": jsonEncode({
              "typ": "Cancel",
            })
          }
        }));
    status = RTCStatus.canceled;
    _dispose();
    afterCanceled?.call();
  }

  refuse() async {
    WS.getOrCreateSink(AuthToken.token).add(jsonEncode({
          "Message": {
            "to": peerID,
            "content": jsonEncode({
              "typ": "Refuse",
            })
          }
        }));
    status = RTCStatus.refused;
    _dispose();
    afterRefused?.call();
  }

  close() async {
    WS.getOrCreateSink(AuthToken.token).add(jsonEncode({
          "Message": {
            "to": peerID,
            "content": jsonEncode({
              "typ": "Close",
            })
          }
        }));
    status = RTCStatus.closed;
    _dispose();
    afterClosed?.call();
  }
}

Future<RTCPeerConnection> createConnection(String peerID) async {
  final peerConn = await createPeerConnection(
    {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    },
    // {
    //   "mandatory": {
    //     "OfferToReceiveVideo": true,
    //   },
    //   "optional": [],
    // }
  );
  peerConn.onIceCandidate = (candidate) {
    WS.getOrCreateSink(AuthToken.token).add(jsonEncode({
          "Message": {
            "to": peerID,
            "content": jsonEncode({
              "typ": "IceCandidate",
              "calleeId": peerID,
              "iceCandidate": {
                "id": candidate.sdpMid,
                "label": candidate.sdpMLineIndex,
                "candidate": candidate.candidate,
              }
            })
          }
        }));
  };
  return peerConn;
}

Future<MediaStream> getUserMedia() async {
  return await navigator.mediaDevices.getUserMedia({
    "audio": false,
    "video": {"facingMode": "user"}
  });
}
