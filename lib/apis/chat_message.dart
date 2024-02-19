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

class SendChatMessage {
  final String to;
  final String mimeType;
  final String content;

  const SendChatMessage(
      {required this.to, required this.mimeType, required this.content});

  Map<String, dynamic> toJson() {
    return {
      "to": to,
      "mime_type": mimeType,
      "content": content,
    };
  }

  factory SendChatMessage.fromJson(Map<String, dynamic> json) {
    return SendChatMessage(
        to: json["to"], mimeType: json["mime_type"], content: json["content"]);
  }
}

Future<ChatMessage> sendChatMessage(
    {required String authToken, required SendChatMessage msg}) async {
  final resp = await post(
      Uri.parse("http://${Config.backendDomain}/apis/v1/chat_messages"),
      headers: {
        "Content-Type": "application/json",
        "X-Auth-Token": authToken,
      });
  if (resp.statusCode != 200) {
    throw Exception("failed to send chat message");
  }
  return ChatMessage.fromJson(jsonDecode(resp.body));
}
