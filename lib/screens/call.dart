import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/webrtc.dart';

class CallScreen extends StatefulWidget {
  final String authToken;
  final RTC rtc;

  const CallScreen({required this.authToken, required this.rtc, super.key});

  @override
  State<StatefulWidget> createState() {
    return _CallScreen();
  }
}

class _CallScreen extends State<CallScreen> {
  @override
  void initState() {
    widget.rtc.afterInitated = () {
      widget.rtc.offer();
      setState(() {});
    };
    widget.rtc.afterAnswered =
        () => context.go("/video", extra: {"rtc": widget.rtc});
    widget.rtc.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rtc.status == RTCStatus.uninitated) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
                  "Calling ${widget.rtc.peerID}...",
                  style: const TextStyle(color: Colors.white),
                ),
                ElevatedButton(
                    onPressed: () {
                      // widget.rtc.dispose();
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
