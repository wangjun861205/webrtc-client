import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/chat_message.dart';
import 'package:webrtc_client/main.dart';

class ChatMessagesCubit extends Cubit<List<ChatMessage>> {
  final String authToken;
  final String peerID;
  late StreamSubscription wsSub;

  ChatMessagesCubit({required this.authToken, required this.peerID})
      : super([]) {
    wsSub = WS.getOrCreateStream(authToken).listen((event) {
      final msg = jsonDecode(event);
      if (msg["typ"] != "ChatMessage" || msg["data"]["from"] != peerID) {
        return;
      }
      final messages = state;
      messages.add(ChatMessage(
          id: msg["data"]["id"],
          from: msg["data"]["from"],
          content: msg["data"]["content"],
          sentAt: DateTime.now().toIso8601String()));
      emit(messages);
    });
  }

  @override
  Future<void> close() {
    wsSub.cancel();
    return super.close();
  }

  void pushMessage(ChatMessage message) {
    final messages = state;
    messages.add(message);
    emit(messages);
  }
}
