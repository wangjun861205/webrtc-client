import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/blocs/friend.dart';
import 'package:webrtc_client/components/friend_search_result.dart';
import 'package:webrtc_client/components/search_friend_input_group.dart';

class SearchFriendScreen extends StatelessWidget {
  final String authToken;
  const SearchFriendScreen({required this.authToken, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => FriendSearchResultCubit(authToken: authToken),
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_sharp),
                onPressed: () => context.go("/"),
              ),
              title: const Text("Search Friends"),
              centerTitle: true,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(child: SearchFriendInputGroup(authToken: authToken)),
                Flexible(
                    child: FriendSearchResult(
                  authToken: authToken,
                ))
              ],
            )));
  }
}
