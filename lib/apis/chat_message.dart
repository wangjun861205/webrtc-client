import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webrtc_client/main.dart';

class ChatMessage {
  final String from;
  final String content;
  final bool isOut;

  const ChatMessage(
      {required this.from, required this.content, required this.isOut});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
        from: json["from"], content: json["content"], isOut: json["is_out"]);
  }
}

Future<List<ChatMessage>> fetchRecentlyMessages(
    {required String authToken, required String to}) async {
  final resp = await get(
      Uri.parse("http://${Config.backendDomain}/apis/v1/chat_messages?to=$to"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to fetch recently messages: ${resp.body}");
  }
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((m) => ChatMessage.fromJson(m))
      .toList();
}
