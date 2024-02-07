import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webrtc_client/apis/chat_message.dart';
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
  late Future<void> future;
  StreamSubscription? sub;
  List<ChatMessage> messages = [];

  Future<void> _fetchMessages() async {
    final msgs =
        await fetchRecentlyMessages(authToken: widget.authToken, to: widget.to);
    setState(() {
      messages.addAll(msgs);
    });
  }

  @override
  void initState() {
    future = _fetchMessages();
    final stream = WS.getOrCreateStream(widget.authToken);
    stream.listen((event) {
      final msg = jsonDecode(event);
      if (msg["typ"] == "ChatMessage") {
        setState(() => messages.add(ChatMessage(
              from: msg["data"]["from"],
              content: msg["data"]["content"],
              isOut: false,
            )));
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
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Column(
              children: [
                Text(snapshot.error.toString()),
                ElevatedButton(
                    onPressed: () => setState(() => future = _fetchMessages()),
                    child: const Text("Retry"))
              ],
            ));
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    return messages[i].isOut
                        ? SizedBox(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                selfAvatar,
                                Text(messages[i].content)
                              ]))
                        : SizedBox(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                Text(messages[i].content),
                                peerAvatar,
                              ]));
                  }));
        });
  }
}
