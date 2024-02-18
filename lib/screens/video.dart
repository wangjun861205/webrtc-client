import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/blocs/rtc.dart';
import 'package:webrtc_client/components/video_view.dart';
import 'package:webrtc_client/webrtc.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rtc = BlocProvider.of<RTCCubit>(context);
    return Scaffold(
        body: Stack(children: [
      Column(
        children: [
          Flexible(flex: 5, child: VideoView(renderer: rtc.localRenderer)),
          Flexible(flex: 5, child: VideoView(renderer: rtc.remoteRenderer))
        ],
      ),
      Center(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(), backgroundColor: Colors.red),
              onPressed: () {
                rtc.cancel();
                rtc.close();
                context.go("/");
              },
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.call_end),
              ))),
    ]));
  }
}
