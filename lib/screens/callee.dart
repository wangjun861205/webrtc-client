import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/webrtc.dart';

class CalleeScreen extends StatefulWidget {
  final String authToken;
  final RTC rtc;

  const CalleeScreen({required this.authToken, required this.rtc, super.key});

  @override
  State<StatefulWidget> createState() {
    return _CalleeScreen();
  }
}

class _CalleeScreen extends State<CalleeScreen> {
  @override
  void initState() {
    widget.rtc.afterAnswered =
        () => context.go("/video", extra: {"rtc": widget.rtc});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        child: Padding(
            padding: const EdgeInsets.only(top: 100, bottom: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.rtc.peerID!),
                Row(children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.rtc.answer();
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
                      widget.rtc.dispose();
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
            )));
  }
}
