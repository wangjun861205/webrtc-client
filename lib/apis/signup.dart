import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webrtc_client/main.dart';

class Signup {
  final String phone;
  final String password;

  const Signup({required this.phone, required this.password});

  Map<String, dynamic> toJson() {
    return {
      "phone": phone,
      "password": password,
    };
  }
}

Future<void> signup({required String phone, required String password}) async {
  debugPrint("==================================");
  debugPrint(Config.backendDomain);
  final resp = await post(
      Uri.parse("http://${Config.backendDomain}/apis/v1/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(Signup(phone: phone, password: password)));
  if (resp.statusCode != HttpStatus.ok) {
    throw Exception("failed to signup(${resp.statusCode}): ${resp.body}");
  }
}
