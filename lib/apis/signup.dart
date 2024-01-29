import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:webrtc_client/apis/common.dart';

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
  final resp = await post(Uri.parse("http://$backendDoamin/apis/v1/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(Signup(phone: phone, password: password)));
  if (resp.statusCode != HttpStatus.ok) {
    throw Exception("failed to signup(${resp.statusCode}): ${resp.body}");
  }
}
