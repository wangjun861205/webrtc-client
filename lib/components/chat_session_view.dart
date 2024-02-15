import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  PagingController _pageCtrl =
      PagingController<String?, ChatMessage>(firstPageKey: null);

  @override
  void initState() {
    _pageCtrl.addPageRequestListener((pageKey) async {
      final messages = await chatMessageHistory(
          authToken: widget.authToken, to: widget.to, limit: 20);
      if (messages.isEmpty) {
        return;
      }
      _pageCtrl.appendPage(messages, messages.first.id);
    });
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
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: ListView.builder(
            itemCount: msgs.state.length,
            itemBuilder: (context, i) {
              return msgs.state[i].from == ""
                  ? SizedBox(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [selfAvatar, Text(msgs.state[i].content)]))
                  : SizedBox(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                          Text(msgs.state[i].content),
                          peerAvatar,
                        ]));
            }));
  }
}
