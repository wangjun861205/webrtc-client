import 'dart:convert';
import 'dart:io';

import 'package:webrtc_client/apis/common.dart';
import 'package:http/http.dart';

Future<String> login({required String email, required password}) async {
  final resp = await put(Uri.parse("$baseURL$login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({email: email, password: password}));
  if (resp.statusCode != HttpStatus.ok) {
    throw Exception(
        "failed to login(status: ${resp.statusCode}): ${resp.body}");
  }
  return jsonDecode(resp.body)["token"];
}
