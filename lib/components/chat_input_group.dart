import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/chat_message.dart';
import 'package:webrtc_client/blocs/chat.dart';
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
    final msgs = BlocProvider.of<ChatMessagesCubit>(context, listen: true);
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 7,
          child: TextField(
            enabled: !(msgs.state.isLoading || msgs.state.error != null),
            controller: textCtrl,
            textInputAction: TextInputAction.send,
          ),
        ),
        Flexible(
          flex: 3,
          child: ElevatedButton(
              onPressed: () {
                msgs.pushMessage(ChatMessage(
                    id: "",
                    from: "",
                    content: textCtrl.text,
                    sentAt: DateTime.now().toIso8601String()));
                WS.getOrCreateSink(widget.authToken).add(jsonEncode({
                      "ChatMessage": {"to": widget.to, "content": textCtrl.text}
                    }));
                textCtrl.clear();
              },
              child: const Text("Send")),
        ),
      ],
    ));
  }
}
