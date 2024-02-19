import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webrtc_client/apis/chat_message.dart';
import 'package:webrtc_client/blocs/common.dart';
import 'package:webrtc_client/main.dart';

class ChatMessagesCubit extends QueryCubit<String?, List<ChatMessage>> {
  final String authToken;
  final String peerID;
  final Function()? afterChange;
  late StreamSubscription wsSub;

  ChatMessagesCubit(
      {required this.authToken, required this.peerID, this.afterChange})
      : super(
            query: Query<String?, List<ChatMessage>>(
                params: null,
                result: [],
                fetchFunc: (String? before) async {
                  return await chatMessageHistory(
                      authToken: authToken, to: peerID, limit: 20);
                },
                handleResultFunc: (
                    {required List<ChatMessage> currResult,
                    required List<ChatMessage> incomeResult}) {
                  currResult.insertAll(0, incomeResult);
                  return currResult;
                },
                nextParamsFunc: (
                    {required String? currParams,
                    required List<ChatMessage> incomeResult}) {
                  if (incomeResult.isEmpty) {
                    return currParams;
                  }
                  return incomeResult.first.id;
                })) {
    wsSub = WS.getOrCreateStream(authToken).listen((event) {
      final msg = jsonDecode(event);
      if (msg["typ"] != "Chat" || msg["from"] != peerID) {
        return;
      }
      final messages = state.result;
      messages.add(ChatMessage(
          id: msg["payload"]["id"],
          from: msg["from"],
          content: msg["payload"]["content"],
          sentAt: DateTime.now().toIso8601String()));
      setResult(messages);
      afterChange?.call();
    });
  }

  @override
  Future<void> close() {
    wsSub.cancel();
    return super.close();
  }

  void pushMessage(ChatMessage message) {
    final messages = state.result;
    messages.add(message);
    setResult(messages);
    afterChange?.call();
  }
}
