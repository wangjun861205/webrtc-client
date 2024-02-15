import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webrtc_client/main.dart';

class Session {
  final String peerID;
  final String peerPhone;
  final int unreadCount;
  final String latestContent;

  const Session(
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

Future<List<Session>> mySessions(
    {required String authToken,
    required int limit,
    required int offset}) async {
  final resp = await get(
      Uri.parse(
          "http://${Config.backendDomain}/apis/v1/me/sessions?limit=$limit&offset=$offset"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to fetch my sessions: ${resp.body}");
  }
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((s) => Session.fromJson(s))
      .toList();
}
