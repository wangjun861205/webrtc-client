import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webrtc_client/apis/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/blocs/chat.dart';
import 'package:webrtc_client/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final WebSocketChannel ws =
      WebSocketChannel.connect(Uri.parse("ws://localhost:8000/apis/v1/ws"));

  @override
  void dispose() {
    super.dispose();
    ws.sink.close();
  }

  Widget input(
      {required TextEditingController controller,
      required Widget label,
      required String hintText,
      bool obscureText = false}) {
    return ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300,
          minWidth: 200,
        ),
        child: TextField(
          obscureText: true,
          controller: controller,
          decoration: InputDecoration(label: label, hintText: hintText),
        ));
  }

  @override
  Widget build(BuildContext context) {
    ws.stream.listen((event) {
      final msg = jsonDecode((event as String));
      switch (msg["typ"]) {
        case "WSError":
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg["reason"])));
        case "LoginResp":
          putAuthToken(msg["data"]["token"]).then((_) => context.push("/"));
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          input(
              controller: phoneCtrl,
              label: const Text("Phone"),
              hintText: "Please enter your phone"),
          input(
              controller: passwordCtrl,
              label: const Text("Password"),
              hintText: "Please enter your password",
              obscureText: true),
          ElevatedButton(
              onPressed: () => ws.sink.add(jsonEncode({
                    "Login": {
                      "username": phoneCtrl.text,
                      "password": passwordCtrl.text
                    }
                  })),
              child: const Text("Login")),
          TextButton(
              onPressed: () => context.go("/signup"),
              child: const Text("Signup"))
        ]),
      ),
    );
  }
}
