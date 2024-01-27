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
      debugPrint(msg.toString());
      switch (msg["typ"]) {
        case "Login":
          loginStreamCtrl.sink.add(msg);
        case "Signup":
          signupStreamCtrl.sink.add(msg);
        case "Logout":
          logoutStreamCtrl.sink.add(msg);
        case "Acquire":
          acquireFriendsStreamCtrl.sink.add(msg);
        case "Message":
          messageStreamCtrl.sink.add(msg);
        case "WSError":
          errorStreamCtrl.sink.add(msg);
      }
    });
  }
}
