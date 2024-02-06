import 'package:flutter/material.dart';
import 'package:webrtc_client/components/chat_input_group.dart';
import 'package:webrtc_client/components/chat_session_view.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  final String authToken;
  final String to;

  const ChatScreen({required this.authToken, required this.to, super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChatScreen();
  }
}

class _ChatScreen extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go("/"),
        ),
        title: const Text("Chat"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ChatSessionView(authToken: widget.authToken, to: widget.to),
          ChatInputGroup(authToken: widget.authToken, to: widget.to)
        ],
      ),
    );
  }
}
