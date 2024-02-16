import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webrtc_client/main.dart';

class Session {
  final String peerID;
  final String peerPhone;
  int unreadCount;
  String latestContent;

  Session(
      {required this.peerID,
      required this.peerPhone,
      required this.unreadCount,
      required this.latestContent});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
        peerID: json["peer_id"],
        peerPhone: json["peer_phone"],
        unreadCount: json["unread_count"],
        latestContent: json["latest_content"]);
  }
}

Future<List<Session>> mySessions({
  required String authToken,
}) async {
  final resp = await get(
      Uri.parse("http://${Config.backendDomain}/apis/v1/me/sessions"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to fetch my sessions: ${resp.body}");
  }
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((s) => Session.fromJson(s))
      .toList();
}
