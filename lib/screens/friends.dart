import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/apis/friend.dart';
import 'package:webrtc_client/blocs/friend.dart';
import 'package:webrtc_client/components/friend_request_list.dart';
import 'package:webrtc_client/components/friends_list.dart';
import 'package:webrtc_client/components/layouts.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => FriendsCubit(authToken: widget.authToken)..load()),
        BlocProvider(create: (_) => FriendRequestsCubit()..next()),
      ],
      child: WithBottomNavigationBar(
          selectedIndex: 1,
          appBar: AppBar(
            title: const Text("Friends"),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_circle_left_outlined),
              onPressed: () => context.go("/"),
            ),
            actions: [
              IconButton(
                  onPressed: () => context.go("/search_friends"),
                  icon: const Icon(Icons.add))
            ],
          ),
          body: Column(
            children: [
              const Flexible(child: FriendRequestList()),
              Flexible(
                child: FriendsList(authToken: widget.authToken),
              )
            ],
          )),
    );
  }
}
