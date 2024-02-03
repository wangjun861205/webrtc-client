import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webrtc_client/main.dart';

class ChatInputGroup extends StatefulWidget {
  final String authToken;
  final String to;

  const ChatInputGroup({required this.authToken, required this.to, super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChatInputGroup();
  }
}

class _ChatInputGroup extends State<ChatInputGroup> {
  final textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Row(
      children: [
        Flexible(
          flex: 7,
          child: TextField(
            controller: textCtrl,
            textInputAction: TextInputAction.send,
          ),
        ),
        Flexible(
          flex: 3,
          child: ElevatedButton(
              onPressed: () {
                WS.getOrCreateSink(widget.authToken).add(jsonEncode({
                      "ChatMessage": {"to": widget.to, "content": textCtrl.text}
                    }));
              },
              child: const Text("Send")),
        ),
      ],
    ));
  }
}
