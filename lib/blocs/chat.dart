import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WSEvent {
  String from;
  int statusCode;
  String typ;
  String payload;

  WSEvent(
      {required this.from,
      required this.statusCode,
      required this.typ,
      required this.payload});

  factory WSEvent.fromJson(Map<String, dynamic> json) {
    return WSEvent(
        from: json["from"],
        statusCode: json["status_code"],
        typ: json["typ"],
        payload: json["payload"]);
  }
}

class LoginResponse {
  String token;

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(token: json["token"]);
  }
}

enum VideoState {
  notReady,
  idle,
  offering,
  beingCalled,
  answered,
}

class Chat {
  final RTCVideoRenderer? localRenderer;
  final RTCVideoRenderer? remoteRenderer;
  final RTCPeerConnection? peerConnection;
  final VideoState? videoState;
  final List<String>? friends;
  final String? selectedFriend;

  Chat({
    this.localRenderer,
    this.remoteRenderer,
    this.peerConnection,
    this.videoState,
    this.friends,
    this.selectedFriend,
  });
}

class ChatCubit extends Cubit<Chat> {
  ChatCubit() : super(Chat(videoState: VideoState.notReady));

  void setLocalRenderer(RTCVideoRenderer? localRenderer) {
    emit(Chat(
      localRenderer: localRenderer,
      remoteRenderer: state.remoteRenderer,
      peerConnection: state.peerConnection,
      videoState: state.videoState,
      friends: state.friends,
      selectedFriend: state.selectedFriend,
    ));
  }

  void setRemoteRender(RTCVideoRenderer? remoteRenderer) {
    emit(Chat(
      localRenderer: state.localRenderer,
      remoteRenderer: remoteRenderer,
      peerConnection: state.peerConnection,
      videoState: state.videoState,
      friends: state.friends,
      selectedFriend: state.selectedFriend,
    ));
  }

  void setPeerConnection(RTCPeerConnection? peerConnection) {
    emit(Chat(
      localRenderer: state.localRenderer,
      remoteRenderer: state.remoteRenderer,
      peerConnection: peerConnection,
      videoState: state.videoState,
      friends: state.friends,
      selectedFriend: state.selectedFriend,
    ));
  }

  void setVideoState(VideoState videoState) {
    emit(Chat(
      localRenderer: state.localRenderer,
      remoteRenderer: state.remoteRenderer,
      peerConnection: state.peerConnection,
      videoState: videoState,
      friends: state.friends,
      selectedFriend: state.selectedFriend,
    ));
  }

  void setFriends(List<String> friends) {
    emit(Chat(
      localRenderer: state.localRenderer,
      remoteRenderer: state.remoteRenderer,
      peerConnection: state.peerConnection,
      videoState: state.videoState,
      friends: friends,
      selectedFriend: state.selectedFriend,
    ));
  }

  void setSelectedFriend(String friend) {
    emit(Chat(
      localRenderer: state.localRenderer,
      remoteRenderer: state.remoteRenderer,
      peerConnection: state.peerConnection,
      videoState: state.videoState,
      friends: state.friends,
      selectedFriend: friend,
    ));
  }
}
