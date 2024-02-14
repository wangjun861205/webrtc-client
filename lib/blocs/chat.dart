import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webrtc_client/apis/chat_message.dart';
import 'package:webrtc_client/utils.dart';

// class WSEvent {
//   String from;
//   int statusCode;
//   String typ;
//   String payload;

//   WSEvent(
//       {required this.from,
//       required this.statusCode,
//       required this.typ,
//       required this.payload});

//   factory WSEvent.fromJson(Map<String, dynamic> json) {
//     return WSEvent(
//         from: json["from"],
//         statusCode: json["status_code"],
//         typ: json["typ"],
//         payload: json["payload"]);
//   }
// }

// class LoginResponse {
//   String token;

//   LoginResponse({required this.token});

//   factory LoginResponse.fromJson(Map<String, dynamic> json) {
//     return LoginResponse(token: json["token"]);
//   }
// }

// enum VideoState {
//   notReady,
//   idle,
//   offering,
//   beingCalled,
//   answered,
// }

// class VideoStateCubit extends Cubit<VideoState> {
//   VideoStateCubit() : super(VideoState.notReady);

//   void set(VideoState state) => emit(state);
// }

// class Chat {
//   final RTCVideoRenderer? localRenderer;
//   final RTCVideoRenderer? remoteRenderer;
//   final RTCPeerConnection? peerConnection;
//   final VideoState? videoState;
//   final List<String>? friends;
//   final String? selectedFriend;

//   Chat({
//     this.localRenderer,
//     this.remoteRenderer,
//     this.peerConnection,
//     this.videoState,
//     this.friends,
//     this.selectedFriend,
//   });
// }

// class ChatCubit extends Cubit<Chat> {
//   ChatCubit() : super(Chat(videoState: VideoState.notReady));

//   void setLocalRenderer(RTCVideoRenderer? localRenderer) {
//     emit(Chat(
//       localRenderer: localRenderer,
//       remoteRenderer: state.remoteRenderer,
//       peerConnection: state.peerConnection,
//       videoState: state.videoState,
//       friends: state.friends,
//       selectedFriend: state.selectedFriend,
//     ));
//   }

//   void setRemoteRender(RTCVideoRenderer? remoteRenderer) {
//     emit(Chat(
//       localRenderer: state.localRenderer,
//       remoteRenderer: remoteRenderer,
//       peerConnection: state.peerConnection,
//       videoState: state.videoState,
//       friends: state.friends,
//       selectedFriend: state.selectedFriend,
//     ));
//   }

//   void setPeerConnection(RTCPeerConnection? peerConnection) {
//     emit(Chat(
//       localRenderer: state.localRenderer,
//       remoteRenderer: state.remoteRenderer,
//       peerConnection: peerConnection,
//       videoState: state.videoState,
//       friends: state.friends,
//       selectedFriend: state.selectedFriend,
//     ));
//   }

//   void setVideoState(VideoState videoState) {
//     emit(Chat(
//       localRenderer: state.localRenderer,
//       remoteRenderer: state.remoteRenderer,
//       peerConnection: state.peerConnection,
//       videoState: videoState,
//       friends: state.friends,
//       selectedFriend: state.selectedFriend,
//     ));
//   }

//   void setFriends(List<String> friends) {
//     emit(Chat(
//       localRenderer: state.localRenderer,
//       remoteRenderer: state.remoteRenderer,
//       peerConnection: state.peerConnection,
//       videoState: state.videoState,
//       friends: friends,
//       selectedFriend: state.selectedFriend,
//     ));
//   }

//   void setSelectedFriend(String friend) {
//     emit(Chat(
//       localRenderer: state.localRenderer,
//       remoteRenderer: state.remoteRenderer,
//       peerConnection: state.peerConnection,
//       videoState: state.videoState,
//       friends: state.friends,
//       selectedFriend: friend,
//     ));
//   }
// }

// class FriendsCubit extends Cubit<List<String>> {
//   FriendsCubit() : super([]);

//   void set(List<String> friends) => emit(friends);
// }

// class SelectedFriendCubit extends Cubit<String?> {
//   SelectedFriendCubit() : super(null);

//   void set(String selected) => emit(selected);
// }

class ChatMessages {
  String to;
  int limit;
  String? before;
  List<ChatMessage> messages;
  bool isLoading;
  Object? error;

  ChatMessages(
      {required this.to,
      required this.limit,
      required this.messages,
      this.before,
      this.isLoading = false,
      this.error});

  ChatMessages copyWithIsLoading(bool isLoading) {
    return ChatMessages(
        to: to,
        limit: limit,
        before: before,
        messages: messages,
        isLoading: isLoading,
        error: null);
  }

  ChatMessages copyWithError(Object error) {
    return ChatMessages(
        to: to,
        limit: limit,
        before: before,
        messages: messages,
        isLoading: false,
        error: error);
  }
}

class ChatMessagesCubit extends Cubit<ChatMessages> {
  ChatMessagesCubit({required String to, required int limit})
      : super(ChatMessages(to: to, limit: limit, messages: []));

  void loadMessages() async {
    emit(state.copyWithIsLoading(true));
    try {
      final resp = await chatMessageHistory(
          authToken: (await getAuthToken())!,
          to: state.to,
          limit: state.limit,
          before: state.before);
      final messages = state.messages;
      messages.insertAll(0, resp);
      emit(ChatMessages(
          to: state.to,
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
        to: state.to,
        limit: state.limit,
        messages: messages,
        before: state.before,
        isLoading: state.isLoading,
        error: state.error));
  }
}
