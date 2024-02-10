import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/main.dart';
import 'package:webrtc_client/webrtc.dart';

class CallScreen extends StatefulWidget {
  final String authToken;
  final String calleeID;

  const CallScreen(
      {required this.authToken, required this.calleeID, super.key});

  @override
  State<StatefulWidget> createState() {
    return _CallScreen();
  }
}

class _CallScreen extends State<CallScreen> {
  late RTCPeerConnection peerConn;
  late StreamSubscription sub;
  late MediaStream localStream;
  bool isReady = false;

  Future<MediaStream> _sendOffer() async {
    final stream = await getUserMedia();
    localStream = stream;
    for (final track in stream.getVideoTracks()) {
      await peerConn.addTrack(track, stream);
    }
    final offer = await peerConn.createOffer({"offerToReceiveVideo": 1});
    await peerConn.setLocalDescription(offer);
    WS.getOrCreateSink(widget.authToken).add(jsonEncode({
          "Message": {
            "to": widget.calleeID,
            "content": jsonEncode(
                {"typ": "Offer", "sdp": offer.sdp, "rtcType": offer.type}),
          }
        }));
    return stream;
  }

  @override
  void initState() {
    sub = WS.getOrCreateStream(widget.authToken).listen((event) {
      final msg = jsonDecode(event);
      if (msg["typ"] == "Message") {
        final content = jsonDecode(msg["data"]["content"]);
        switch (content["typ"]) {
          case "Answer":
            final description =
                RTCSessionDescription(content["sdp"], content["rtcType"]);
            peerConn.setRemoteDescription(description).then((_) {
              context.go("/video",
                  extra: {"localStream": localStream, "peerConn": peerConn});
            });
          case "Refuse":
            peerConn.close();
            sub.cancel();
            context.go("/");
          case "IceCandidate":
            final candidate = content["iceCandidate"]["candidate"];
            final sdpMid = content["iceCandidate"]["id"];
            final sdpMLineIndex = content["iceCandidate"]["label"];
            peerConn.addCandidate(
                RTCIceCandidate(candidate, sdpMid, sdpMLineIndex));
        }
      }
    });
    createConnection(widget.calleeID).then((conn) {
      peerConn = conn;
      // peerConn.onIceCandidate = (candidate) => candidates.add(candidate);
      _sendOffer().then((localStream) => setState(() {
            // localStream = localStream;
            isReady = true;
          }));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: !isReady
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.only(top: 100, bottom: 100),
                child: Align(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Calling ${widget.calleeID}...",
                      style: const TextStyle(color: Colors.white),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          context.go("/");
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.red,
                        ),
                        child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.call_end,
                              size: 50,
                              color: Colors.white,
                            )))
                  ],
                ))));
  }
}
