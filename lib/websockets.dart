import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum MessageType {
  @JsonValue("offer")
  offer,
  @JsonValue("answer")
  answer,
}

class Message<T> {
  final MessageType type;
  final T? content;

  const Message({required this.type, this.content});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        type: json["type"] as MessageType, content: json["type"] as T?);
  }

  Map<String, dynamic> toJson() {
    return {"type": jsonEncode(type), "content": jsonEncode(content)};
  }
}

class WebSocketConn {
  final String url;
  final void Function<T>(Message<T> msg, void Function(Message msg) send)
      onMessage;
  late WebSocketChannel channel;

  WebSocketConn({required this.url, required this.onMessage}) {
    channel = WebSocketChannel.connect(Uri.parse(url))
      ..stream.listen((event) => onMessage(event, send));
  }

  void send(Message msg) => channel.sink.add(msg);
}
