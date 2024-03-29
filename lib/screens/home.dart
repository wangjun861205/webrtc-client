import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/blocs/session.dart';
import 'package:webrtc_client/components/layouts.dart';
import 'package:webrtc_client/components/session_list.dart';
import 'package:webrtc_client/components/friends_screen_button.dart';
import 'package:webrtc_client/components/me_nav_button.dart';
import 'package:webrtc_client/webrtc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  final String authToken;
  const HomeScreen({required this.authToken, super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> {
  RTC rtc = RTC();

  @override
  void dispose() {
    rtc.afterInitated = null;
    rtc.afterBeingCalled = null;
    super.dispose();
  }

  @override
  initState() {
    rtc.afterInitated = () => setState(() {});
    rtc.afterBeingCalled = () => context.go("/callee", extra: {"rtc": rtc});
    rtc.init();
    super.initState();
  }

  _HomeScreen();

  @override
  Widget build(BuildContext context) {
    if (rtc.status == RTCStatus.uninitated) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocProvider(
        create: (_) => SessionsCubit(authToken: widget.authToken)..next(),
        child: WithBottomNavigationBar(
            selectedIndex: 0,
            appBar: AppBar(
              title: const Text("Home"),
              centerTitle: true,
            ),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 300,
                    child: SessionList(
                      limit: 20,
                      authToken: widget.authToken,
                    ),
                  ),
                ])));
  }
}
