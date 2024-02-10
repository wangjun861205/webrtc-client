import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/components/video_view.dart';
import 'package:webrtc_client/webrtc.dart';

class VideoScreen extends StatefulWidget {
  final String authToken;
  final RTC rtc;

  const VideoScreen({required this.authToken, required this.rtc, super.key});

  @override
  State<StatefulWidget> createState() {
    return _VideoScreen();
  }
}

class _VideoScreen extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Column(
        children: [
          Flexible(
              flex: 5, child: VideoView(renderer: widget.rtc.localRenderer!)),
          Flexible(
              flex: 5, child: VideoView(renderer: widget.rtc.remoteRenderer!))
        ],
      ),
      Positioned(
          top: MediaQuery.of(context).size.height * 0.5,
          left: MediaQuery.of(context).size.width * 0.5,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(), backgroundColor: Colors.red),
            onPressed: () {
              // widget.rtc.dispose();
              context.go("/");
            },
            child: const Icon(Icons.call_end),
          )),
    ]));
  }
}
