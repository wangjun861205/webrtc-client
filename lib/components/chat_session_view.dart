import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/chat_message.dart';
import 'package:webrtc_client/blocs/chat.dart';
import 'package:webrtc_client/main.dart';

class ChatSessionView extends StatefulWidget {
  final String authToken;
  final String to;

  const ChatSessionView({required this.authToken, required this.to, super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChatSessionView();
  }
}

class _ChatSessionView extends State<ChatSessionView> {
  StreamSubscription? sub;

  @override
  void initState() {
    final msgs = BlocProvider.of<ChatMessagesCubit>(context);
    msgs.loadMessages();
    final stream = WS.getOrCreateStream(widget.authToken);
    sub = stream.listen((event) {
      final msg = jsonDecode(event);
      if (msg["typ"] == "ChatMessage") {
        setState(() => msgs.pushMessage(ChatMessage(
            id: msg["id"],
            from: msg["data"]["from"],
            content: msg["data"]["content"],
            sentAt: msg["data"]["sent_at"])));
      }
    }, onDone: () => setState(() => sub = null));
    super.initState();
  }

  @override
  void deactivate() {
    sub?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final selfAvatar = CircleAvatar(
      radius: 25,
      backgroundImage: NetworkImage(
          "http://${Config.backendDomain}/apis/v1/me/avatar",
          headers: {"X-Auth-Token": widget.authToken}),
    );
    final peerAvatar = CircleAvatar(
      radius: 25,
      backgroundImage: NetworkImage(
          "http://${Config.backendDomain}/apis/v1/users/${widget.to}/avatar",
          headers: {"X-Auth-Token": widget.authToken}),
    );
    final msgs = BlocProvider.of<ChatMessagesCubit>(context, listen: true);
    if (msgs.state.error != null) {
      return Center(
          child: Column(children: [
        Text(msgs.state.error.toString()),
        ElevatedButton(
            onPressed: () => msgs.loadMessages(), child: const Text("Retry"))
      ]));
    }
    if (msgs.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: ListView.builder(
            itemCount: msgs.state.messages.length,
            itemBuilder: (context, i) {
              return msgs.state.messages[i].from == ""
                  ? SizedBox(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                          selfAvatar,
                          Text(msgs.state.messages[i].content)
                        ]))
                  : SizedBox(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                          Text(msgs.state.messages[i].content),
                          peerAvatar,
                        ]));
            }));
  }
}
