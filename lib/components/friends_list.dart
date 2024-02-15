import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/blocs/friend.dart';
import 'package:webrtc_client/main.dart';

class FriendsList extends StatelessWidget {
  final String authToken;

  const FriendsList({required this.authToken, super.key});

  @override
  Widget build(BuildContext context) {
    final friends = BlocProvider.of<FriendsCubit>(context, listen: true);
    if (friends.state.error != null) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(friends.state.error.toString()),
          ElevatedButton(
              onPressed: () => friends.load(), child: const Text("Retry"))
        ],
      ));
    }
    if (friends.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: friends.state.friends
          .map((f) => ListTile(
              leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      "http://${Config.backendDomain}/apis/v1/uploads/${f.avatar}",
                      headers: {"X-Auth-Token": authToken})),
              title: Text(f.phone),
              onTap: () => context.go("/chat?to=${f.id}")))
          .toList(),
    );
  }
}
