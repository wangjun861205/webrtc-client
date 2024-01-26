import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WS {
  final WebSocketChannel ws;
  late Stream loginStream;
  late Stream signupStream;
  late Stream logoutStream;
  late Stream acquireFriendsStream;
  late Stream messageStream;
  late Stream errorStream;

  WS({required this.ws}) {
    late StreamController loginStreamCtrl = StreamController();
    late StreamController signupStreamCtrl = StreamController();
    late StreamController logoutStreamCtrl = StreamController();
    late StreamController acquireFriendsStreamCtrl = StreamController();
    late StreamController messageStreamCtrl = StreamController();
    late StreamController errorStreamCtrl = StreamController();
    loginStream = loginStreamCtrl.stream;
    signupStream = signupStreamCtrl.stream;
    logoutStream = logoutStreamCtrl.stream;
    acquireFriendsStream = acquireFriendsStreamCtrl.stream;
    messageStream = messageStreamCtrl.stream;
    errorStream = errorStreamCtrl.stream;
    ws.stream.listen((event) {
      final msg = jsonDecode(event as String);
      switch (msg["typ"]) {
        case "LoginResp":
          loginStreamCtrl.sink.add(msg);
        case "SignupResp":
          signupStreamCtrl.sink.add(msg);
        case "LogoutResp":
          logoutStreamCtrl.sink.add(msg);
        case "AcquireFriends":
          acquireFriendsStreamCtrl.sink.add(msg);
        case "Message":
          messageStreamCtrl.sink.add(msg);
        case "WSError":
          errorStreamCtrl.sink.add(msg);
      }
    });
  }
}
