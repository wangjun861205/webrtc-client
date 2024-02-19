import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/chat_message.dart';
import 'package:webrtc_client/blocs/chat.dart';
import 'package:webrtc_client/blocs/common.dart';
import 'package:webrtc_client/blocs/me.dart';
import 'package:webrtc_client/main.dart';
import 'package:webrtc_client/screens/error.dart';

class ChatSessionView extends StatefulWidget {
  final String authToken;
  final String to;
  final ScrollController scrollCtrl = ScrollController();

  ChatSessionView({required this.authToken, required this.to, super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChatSessionView();
  }
}

class _ChatSessionView extends State<ChatSessionView> {
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
      return ErrorScreen(error: msgs.state.error, retry: () => setState(() {}));
    }
    if (msgs.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final me = BlocProvider.of<MeCubit>(context, listen: true);
    if (me.state.error != null) {
      return ErrorScreen(error: me.state.error, retry: () => setState(() {}));
    }
    WidgetsBinding.instance.addPostFrameCallback((d) {
      widget.scrollCtrl.animateTo(widget.scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    });
    return ListView.builder(
        controller: widget.scrollCtrl,
        itemCount: msgs.state.result.length,
        itemBuilder: (context, i) {
          return msgs.state.result[i].from == me.state.me!.id
              ? SizedBox(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                      selfAvatar,
                      msgs.state.result[i].mimeType == "text/plain"
                          ? Text(msgs.state.result[i].content)
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.5),
                              child: Image.memory(
                                base64Decode(msgs.state.result[i].content),
                              ))
                    ]))
              : SizedBox(
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  msgs.state.result[i].mimeType == "text/plain"
                      ? Text(msgs.state.result[i].content)
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.5),
                          child: Image.memory(
                            base64Decode(msgs.state.result[i].content),
                          )),
                  peerAvatar,
                ]));
        });
  }
}
