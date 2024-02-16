import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webrtc_client/main.dart';

class ChatMessage {
  final String id;
  final String from;
  final String content;
  final String sentAt;
  const ChatMessage(
      {required this.id,
      required this.from,
      required this.content,
      required this.sentAt});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
        id: json["id"],
        from: json["from"],
        content: json["content"],
        sentAt: json["sent_at"]);
  }
}

Future<List<ChatMessage>> chatMessageHistory(
    {required String authToken,
    required String to,
    required int limit,
    String? before}) async {
  final resp = await get(
    Uri.parse(
        "http://${Config.backendDomain}/apis/v1/chat_messages?to=$to&limit=$limit${before != null ? "&before=$before" : ""}"),
    headers: {"X-Auth-Token": authToken},
  );
  if (resp.statusCode != 200) {
    throw Exception("failed to fetch chat message history: ${resp.body}");
  }
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((m) => ChatMessage.fromJson(m))
      .toList();
}
