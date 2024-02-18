import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/blocs/rtc.dart';
import 'package:webrtc_client/screens/video.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rtc = BlocProvider.of<RTCCubit>(context, listen: true);
    if (rtc.state.error != null) {
      return Center(
          child: Column(
        children: [
          Text(rtc.state.error.toString()),
          ElevatedButton(
              onPressed: () {
                rtc.close();
                context.go("/");
              },
              child: const Text("Go home"))
        ],
      ));
    }
    if (rtc.state.status == RTCStatus.initiating) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (rtc.state.status == RTCStatus.canceled ||
        rtc.state.status == RTCStatus.refused) {
      rtc.close();
      context.go("/");
      return Container();
    }
    if (rtc.state.status == RTCStatus.answered) {
      return const VideoScreen();
    }
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
                  "Calling ${rtc.peerPhone}...",
                  style: const TextStyle(color: Colors.white),
                ),
                ElevatedButton(
                    onPressed: () {
                      rtc.cancel();
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
