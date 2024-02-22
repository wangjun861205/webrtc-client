import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:webrtc_client/blocs/me.dart';
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

Future<void> updateFCMToken(String authToken, fcmToken) async {
  final resp = await put(
      Uri.parse("http://${Config.backendDomain}/apis/v1/me/notification_token"),
      headers: {"X-Auth-Token": authToken, "Content-Type": "application/json"},
      body: jsonEncode({"token": fcmToken}));
  if (resp.statusCode != 200) {
    throw Exception("failed to update FCM token: ${resp.body}");
  }
}

Future<void> verifyAuthToken(String authToken) async {
  final resp = await get(Uri.parse("http://${Config.backendDomain}/apis/v1"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to verify auth token");
  }
}

Future<Me?> me(String authToken) async {
  final resp = await get(Uri.parse("http://${Config.backendDomain}/apis/v1/me"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode == 403 || resp.statusCode == 401) {
    return null;
  }
  if (resp.statusCode != 200) {
    throw Exception("failed to get my info: ${resp.body}");
  }
  final json = jsonDecode(resp.body);
  return Me.fromJson(json);
}

Future<void> logout(String authToken) async {
  final resp = await delete(Uri.parse("http://${Config.backendDomain}/logout"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to logout: ${resp.body}");
  }
}
