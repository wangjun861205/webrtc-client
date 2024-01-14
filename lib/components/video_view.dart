import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoView extends StatelessWidget {
  final RTCVideoRenderer renderer;

  const VideoView({required this.renderer, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('local'),
      margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      decoration: const BoxDecoration(color: Colors.black),
      child: RTCVideoView(renderer),
    );
  }
}
