import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/apis/friend.dart';
import 'package:webrtc_client/blocs/ws.dart';
import 'package:webrtc_client/main.dart';

class FriendsScreenButton extends StatefulWidget {
  final String authToken;

  const FriendsScreenButton({required this.authToken, super.key});

  @override
  State<StatefulWidget> createState() {
    return _FriendsScreenButton();
  }
}

class _FriendsScreenButton extends State<FriendsScreenButton> {
  late Future<int> future;
  late StreamSubscription? sub;

  @override
  void initState() {
    super.initState();
    future = numOfFriendRequests(widget.authToken);
  }

  @override
  void deactivate() async {
    super.deactivate();
    sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (WS.stream == null) {
      context.go("/login");
      return Container();
    }
    sub = WS.stream!.listen((event) {
      final map = jsonDecode(event);
      if (map["typ"] == "AddFriend") {
        setState(() {
          future = numOfFriendRequests(widget.authToken);
        });
      }
    });
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TextButton(
                onPressed: () {
                  setState(
                      () => future = numOfFriendRequests(widget.authToken));
                },
                child: const Text("Retry"));
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return Stack(
            children: [
              IconButton(
                  onPressed: () {
                    context.go("/friends");
                  },
                  icon: const Icon(Icons.contacts)),
              if (snapshot.data! > 0)
                Positioned(
                    right: 0,
                    child: Container(
                        alignment: Alignment.center,
                        constraints:
                            const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(9)),
                        child: Text(
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                            snapshot.data.toString())))
            ],
          );
        });
  }
}
