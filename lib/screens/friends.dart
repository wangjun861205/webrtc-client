import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/apis/friend.dart';
import 'package:webrtc_client/components/friend_request_list.dart';
import 'package:webrtc_client/components/user_list.dart';

class FriendsScreen extends StatefulWidget {
  final String authToken;

  const FriendsScreen({required this.authToken, super.key});

  @override
  State<StatefulWidget> createState() {
    return _FriendsScreen();
  }
}

class _FriendsScreen extends State<FriendsScreen> {
  List<User> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Friends"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_circle_left_outlined),
            onPressed: () => context.go("/"),
          ),
        ),
        body: Column(
          children: [
            FriendRequestList(
              authToken: widget.authToken,
            ),
            UserList(
              authToken: widget.authToken,
            )
          ],
        ));
  }
}
