import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/apis/me.dart';
import 'package:webrtc_client/utils.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WelcomScreen();
  }
}

class _WelcomScreen extends State<WelcomeScreen> {
  double opacity = 1.0;

  @override
  void initState() {
    getAuthToken().then((token) {
      if (token == null) {
        context.go("/login");
        return;
      }
      verifyAuthToken(token).then((_) {
        context.go("/");
      }, onError: (_) {
        context.go("/login");
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            onEnd: () => setState(() => opacity == 1.0 ? 0.0 : 1.0),
            child: const Center(
                child: Text("Welcome",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)))));
  }
}
