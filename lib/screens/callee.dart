import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/main.dart';
import 'package:webrtc_client/webrtc.dart';

class CalleeScreen extends StatefulWidget {
  final String authToken;
  final String callID;
  final RTCSessionDescription description;

  const CalleeScreen(
      {required this.authToken,
      required this.callID,
      required this.description,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return _CalleeScreen();
  }
}

class _CalleeScreen extends State<CalleeScreen> {
  late RTCPeerConnection peerConn;
  late StreamSubscription sub;

  @override
  void dispose() {
    peerConn.close();
    sub.cancel();
    super.dispose();
  }

  @override
  void initState() {
    sub = WS.getOrCreateStream(widget.authToken).listen((event) {
      final msg = jsonDecode(event);
      if (msg["typ"] == "Message") {
        final content = jsonDecode(msg["data"]["content"]);
        if (content["typ"] == "IceCandidate") {
          final candidate = content["iceCandidate"]["candidate"];
          final sdpMid = content["iceCandidate"]["id"];
          final sdpMLineIndex = content["iceCandidate"]["label"];
          peerConn
              .addCandidate(RTCIceCandidate(candidate, sdpMid, sdpMLineIndex));
        }
      }
    });
    createConnection().then((conn) => peerConn = conn);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
            child: Padding(
                padding: const EdgeInsets.only(top: 100, bottom: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.callID),
                    Row(children: [
                      ElevatedButton(
                        onPressed: () async {
                          final localStream = await getUserMedia();
                          for (final track in localStream.getTracks()) {
                            peerConn.addTrack(track, localStream);
                          }
                          peerConn.addStream(localStream);
                          await peerConn
                              .setRemoteDescription(widget.description);
                          final answer = await peerConn.createAnswer({
                            "offerToReceiveVideo": 1,
                            "offerToReceiveAudio": 1
                          });
                          await peerConn.setLocalDescription(answer);
                          WS.getOrCreateSink(widget.authToken).add(jsonEncode({
                                "Message": {
                                  "to": widget.callID,
                                  "content": jsonEncode({
                                    "typ": "Answer",
                                    "sdp": answer.sdp,
                                    "rtcType": answer.type,
                                  })
                                }
                              }));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: const CircleBorder()),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.call),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          WS.getOrCreateSink(widget.authToken).add(jsonEncode({
                                "Message": {
                                  "to": widget.callID,
                                  "content": jsonEncode({
                                    "typ": "Refuse",
                                  })
                                }
                              }));
                          peerConn.close();
                          sub.cancel();
                          context.go("/");
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: const CircleBorder()),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.call_end),
                        ),
                      )
                    ])
                  ],
                ))));
  }
}
