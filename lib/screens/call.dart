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

  @override
  void initState() {
    createConnection().then((conn) {
      peerConn = conn;
      peerConn.createOffer(
          {"offerToReceiveVideo": 1, "offerToReceiveAudio": 1}).then((offer) {
        peerConn.setLocalDescription(offer);
        WS.getOrCreateSink(widget.authToken).add(jsonEncode({
              "Message": {
                "to": widget.calleeID,
                "content": jsonEncode({"typ": "Offer", "data": offer.sdp}),
              }
            }));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
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
