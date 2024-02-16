import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/session.dart';
import 'package:webrtc_client/blocs/common.dart';
import 'package:webrtc_client/main.dart';

class SessionCubit extends Cubit<Session> {
  final String authToken;
  late StreamSubscription wsSub;
  SessionCubit({required this.authToken, required Session session})
      : super(session) {
    wsSub = WS.getOrCreateStream(AuthToken.token).listen((event) {
      final json = jsonDecode(event);
      if (json["typ"] != "ChatMessage" ||
          json["data"]["from"] != state.peerID) {
        return;
      }
      emit(Session(
          peerID: state.peerID,
          peerPhone: state.peerPhone,
          unreadCount: state.unreadCount + 1,
          latestContent: json["data"]["content"]));
    });
  }

  @override
  Future<void> close() {
    wsSub.cancel();
    return super.close();
  }
}

class SessionsCubit extends QueryCubit<void, List<Session>> {
  final String authToken;
  late StreamSubscription wsSub;

  SessionsCubit({
    required this.authToken,
  }) : super(
            query: Query(
                params: null,
                result: [],
                fetchFunc: (void params) async {
                  return await mySessions(authToken: authToken);
                },
                handleResultFunc: (
                        {required List<Session> currResult,
                        required List<Session> incomeResult}) =>
                    incomeResult,
                nextParamsFunc: (
                    {required void currParams,
                    required List<Session> incomeResult}) {})) {
    wsSub = WS.getOrCreateStream(authToken).listen((event) {
      final json = jsonDecode(event);
      if (json["typ"] != "ChatMessage") {
        return;
      }
      final sessions = state.result;
      final target = sessions
          .where((element) => element.peerID == json["data"]["from"])
          .firstOrNull;
      if (target != null) {
        target.latestContent = json["data"]["content"];
        target.unreadCount += 1;
      } else {
        sessions.add(Session(
            peerID: json["data"]["from"],
            peerPhone: json["data"]["phone"],
            unreadCount: 1,
            latestContent: json["data"]["content"]));
      }
      emit(Query(
          params: null,
          result: sessions,
          fetchFunc: state.fetchFunc,
          handleResultFunc: state.handleResultFunc,
          nextParamsFunc: state.nextParamsFunc));
    });
  }

  @override
  Future<void> close() {
    wsSub.cancel();
    return super.close();
  }
}
