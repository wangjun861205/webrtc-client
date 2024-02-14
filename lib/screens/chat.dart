import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/blocs/chat.dart';
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
    return BlocProvider(
        create: (_) =>
            ChatMessagesCubit(to: widget.to, limit: 20)..loadMessages(),
        child: Scaffold(
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
              Flexible(
                flex: 8,
                child:
                    ChatSessionView(authToken: widget.authToken, to: widget.to),
              ),
              Flexible(
                  flex: 2,
                  child: ChatInputGroup(
                      authToken: widget.authToken, to: widget.to))
            ],
          ),
        ));
  }
}
