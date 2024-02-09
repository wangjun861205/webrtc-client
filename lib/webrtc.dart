import 'package:flutter_webrtc/flutter_webrtc.dart';

Future<RTCPeerConnection> createConnection() async {
  return await createPeerConnection({
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ]
  }, {
    "mandatory": {
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  });
}

Future<MediaStream> getUserMedia() async {
  return await navigator.mediaDevices.getUserMedia({
    "audio": false,
    "video": {"facingMode": "user"}
  });
}
