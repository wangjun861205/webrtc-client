import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/chat_message.dart';
import 'package:webrtc_client/main.dart';
import 'package:webrtc_client/utils.dart';

class ChatMessages {
  String peerID;
  int limit;
  String? before;
  List<ChatMessage> messages;
  bool isLoading;
  Object? error;
  int unreadCount;

  ChatMessages({
    required this.peerID,
    required this.limit,
    required this.messages,
    this.before,
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  ChatMessages copyWithIsLoading(bool isLoading) {
    return ChatMessages(
      peerID: peerID,
      limit: limit,
      before: before,
      messages: messages,
      isLoading: isLoading,
      error: null,
      unreadCount: unreadCount,
    );
  }

  ChatMessages copyWithError(Object error) {
    return ChatMessages(
        peerID: peerID,
        limit: limit,
        before: before,
        messages: messages,
        isLoading: false,
        error: error,
        unreadCount: unreadCount);
  }
}

class ChatMessagesCubit extends Cubit<ChatMessages> {
  late StreamSubscription wsSub;

  ChatMessagesCubit(
      {required String authToken, required String peerID, required int limit})
      : super(ChatMessages(peerID: peerID, limit: limit, messages: [])) {
    wsSub = WS.getOrCreateStream(authToken).listen((event) {
      final msg = jsonDecode(event);
      if (msg["typ"] != "ChatMessage" || msg["data"]["from"] != peerID) {
        return;
      }
      final messages = state.messages;
      messages.add(ChatMessage(
          id: msg["data"]["id"],
          from: msg["data"]["from"],
          content: msg["data"]["content"],
          sentAt: DateTime.now().toIso8601String()));
      emit(ChatMessages(
          peerID: state.peerID,
          limit: state.limit,
          messages: messages,
          before: state.before,
          isLoading: state.isLoading,
          error: state.error,
          unreadCount: state.unreadCount + 1));
    });
  }

  @override
  Future<void> close() {
    wsSub.cancel();
    return super.close();
  }

  void loadMessages() async {
    emit(state.copyWithIsLoading(true));
    try {
      final resp = await chatMessageHistory(
          authToken: (await getAuthToken())!,
          to: state.peerID,
          limit: state.limit,
          before: state.before);
      final messages = state.messages;
      messages.insertAll(0, resp);
      emit(ChatMessages(
          peerID: state.peerID,
          limit: state.limit,
          messages: messages,
          before: resp.lastOrNull != null ? resp.last.id : state.before,
          isLoading: false,
          error: null));
    } catch (err) {
      emit(state.copyWithError(err));
    }
  }

  void pushMessage(ChatMessage message) {
    final messages = state.messages;
    messages.add(message);
    emit(ChatMessages(
        peerID: state.peerID,
        limit: state.limit,
        messages: messages,
        before: state.before,
        isLoading: state.isLoading,
        error: state.error));
  }
}
