import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webrtc_client/apis/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webrtc_client/apis/signup.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/blocs/ws.dart';
import 'package:webrtc_client/main.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final WS ws;

  SignupScreen({required this.ws, super.key});

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
    return StreamBuilder(
        stream: ws.signupStream,
        builder: (context, signupResp) => StreamBuilder(
            stream: ws.errorStream,
            builder: (context, error) {
              if (error.hasData) {
                debugPrint("============================");
                debugPrint(error.data.toString());
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.data["reason"].toString())));
              }
              if (signupResp.hasData) {
                context.pop();
              }
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Signup"),
                  centerTitle: true,
                ),
                body: Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                            onPressed: () {
                              ws.ws.sink.add({
                                "Signup": {
                                  "username": phoneCtrl.text,
                                  "password": passwordCtrl.text
                                }
                              });
                            },
                            child: const Text("Signup"))
                      ]),
                ),
              );
            }));
  }
}
