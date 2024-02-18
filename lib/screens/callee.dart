import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/blocs/rtc.dart';
import 'package:webrtc_client/screens/video.dart';

class CalleeScreen extends StatelessWidget {
  const CalleeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rtc = BlocProvider.of<RTCCubit>(context);
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
    if (rtc.state.status == RTCStatus.canceled ||
        rtc.state.status == RTCStatus.refused) {
      rtc.close();
      context.go("/");
      return Container();
    }
    if (rtc.state.status == RTCStatus.answered) {
      return VideoScreen();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Align(
          child: Padding(
              padding: const EdgeInsets.only(top: 100, bottom: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    rtc.peerID,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            rtc.accept();
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
                            rtc.refuse();
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
              ))),
    );
  }
}
