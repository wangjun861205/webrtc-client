import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/session.dart';
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
          unreadCount: state.unreadCount + 1));
    });
  }

  @override
  Future<void> close() {
    wsSub.cancel();
    return super.close();
  }
}
