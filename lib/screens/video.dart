import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/components/video_view.dart';
import 'package:webrtc_client/main.dart';

class VideoScreen extends StatefulWidget {
  final String authToken;
  final MediaStream localStream;
  final RTCPeerConnection peerConn;

  const VideoScreen(
      {required this.authToken,
      required this.localStream,
      required this.peerConn,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return _VideoScreen();
  }
}

class _VideoScreen extends State<VideoScreen> {
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  late StreamSubscription sub;

  @override
  void deactivate() {
    for (final track in widget.localStream.getTracks()) {
      track.stop();
    }
    super.deactivate();
  }

  @override
  void initState() {
    sub = WS.getOrCreateStream(widget.authToken).listen((event) {
      final msg = jsonDecode(event);
      if (msg["typ"] != "Message") {
        return;
      }
      final content = jsonDecode(msg["data"]["content"]);
      if (content["typ"] != "IceCandidate") {
        return;
      }
      final candidate = content["iceCandidate"]["candidate"];
      final sdpMid = content["iceCandidate"]["id"];
      final sdpMLineIndex = content["iceCandidate"]["label"];
      widget.peerConn
          .addCandidate(RTCIceCandidate(candidate, sdpMid, sdpMLineIndex));
    });
    localRenderer.initialize().then((_) {
      localRenderer.srcObject = widget.localStream;
    });
    remoteRenderer.initialize().then((_) {
      debugPrint(
          "length of remote streams: ${widget.peerConn.getRemoteStreams().length}");
      remoteRenderer.srcObject = widget.peerConn.getRemoteStreams()[0];
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Column(
        children: [
          Flexible(flex: 5, child: VideoView(renderer: localRenderer)),
          Flexible(flex: 5, child: VideoView(renderer: remoteRenderer))
        ],
      ),
      Positioned(
          top: MediaQuery.of(context).size.height * 0.5,
          left: MediaQuery.of(context).size.width * 0.5,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(), backgroundColor: Colors.red),
            onPressed: () {
              localRenderer.dispose();
              remoteRenderer.dispose();
              widget.localStream.dispose();
              widget.peerConn.close();
              context.go("/");
            },
            child: const Icon(Icons.call_end),
          )),
    ]));
  }
}
