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
            controller: textCtrl,
            textInputAction: TextInputAction.send,
          ),
        ),
        Flexible(
          flex: 3,
          child: ElevatedButton(
              onPressed: () {
                sendChatMessage(
                        authToken: AuthToken.token,
                        msg: SendChatMessage(
                            to: widget.to,
                            mimeType: "plain/text",
                            content: textCtrl.text))
                    .then((m) {
                  msgs.pushMessage(m);
                  textCtrl.clear();
                },
                        onError: (err) => ScaffoldMessenger.of(context)
                            .showSnackBar(
                                SnackBar(content: Text(err.toString()))));
              },
              child: const Text("Send")),
        ),
      ],
    ));
  }
}
