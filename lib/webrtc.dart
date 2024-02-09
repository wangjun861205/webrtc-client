import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_client/main.dart';

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
    debugPrint("onIceCandidate: ${candidate.sdpMLineIndex}");
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
