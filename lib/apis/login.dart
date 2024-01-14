import 'dart:convert';
import 'dart:io';

import 'package:webrtc_client/apis/common.dart';
import 'package:http/http.dart';

Future<String> login(String email, password) async {
  final resp = await put(Uri.parse(baseURL + "login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({email: email, password: password}));
  if (resp.statusCode != HttpStatus.ok) {
    throw Exception("failed to login: ${resp.body}");
  }
  return resp.body;
}
