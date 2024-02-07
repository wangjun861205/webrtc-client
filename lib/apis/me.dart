import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:webrtc_client/main.dart';

Future<void> upsertAvatar(
    {required String authToken, required String uploadID}) async {
  final resp = await put(
      Uri.parse("http://${Config.backendDomain}/apis/v1/me/avatar"),
      headers: {"X-Auth-Token": authToken, "Content-Type": "application/json"},
      body: jsonEncode({"upload_id": uploadID}));
  if (resp.statusCode != HttpStatus.ok) {
    throw Exception("failed to upsert avatar: ${resp.body}");
  }
}
