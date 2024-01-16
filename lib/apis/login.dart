import 'dart:convert';
import 'dart:io';

import 'package:webrtc_client/apis/common.dart';
import 'package:http/http.dart';

class LoginReq {
  final String email;
  final String password;

  const LoginReq({required this.email, required this.password});
}

Future<String> login({required String email, required String password}) async {
  final resp = await put(Uri.parse("$baseURL/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(LoginReq(email: email, password: password)));
  if (resp.statusCode != HttpStatus.ok) {
    throw Exception(
        "failed to login(status: ${resp.statusCode}): ${resp.body}");
  }
  return jsonDecode(resp.body)["token"];
}
