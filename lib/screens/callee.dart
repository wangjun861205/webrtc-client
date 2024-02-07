import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/main.dart';
import 'package:webrtc_client/screens/call.dart';
import 'package:webrtc_client/webrtc.dart';

class CalleeScreen extends StatefulWidget {
  final String authToken;
  final String callID;
  final String sdp;

  const CalleeScreen(
      {required this.authToken,
      required this.callID,
      required this.sdp,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return _CalleeScreen();
  }
}

class _CalleeScreen extends State<CalleeScreen> {
  late RTCPeerConnection peerConn;

  @override
  void initState() {
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
                          peerConn.addStream(localStream);
                          final answer = await peerConn.createAnswer({
                            "offerToReceiveVideo": 1,
                            "offerToReceiveAudio": 1
                          });
                          peerConn.setLocalDescription(answer);
                          WS.getOrCreateSink(widget.authToken).add(jsonEncode({
                                "Message": {
                                  "to": widget.callID,
                                  "content": {
                                    "typ": "Answer",
                                    "data": answer.sdp,
                                  }
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
                                  "content": {
                                    "typ": "Refuse",
                                  }
                                }
                              }));
                          peerConn.close();
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
