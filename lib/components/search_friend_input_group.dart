import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/blocs/friend.dart';

class SearchFriendInputGroup extends StatelessWidget {
  final String authToken;
  final TextEditingController ctrl = TextEditingController();

  SearchFriendInputGroup({required this.authToken, super.key});

  @override
  Widget build(BuildContext context) {
    final searchResult =
        BlocProvider.of<FriendSearchResultCubit>(context, listen: true);
    if (searchResult.state.error != null) {
      return Center(
          child: Column(
        children: [
          Text(searchResult.state.error.toString()),
          ElevatedButton(
              onPressed: () => searchResult.next(), child: const Text("Retry"))
        ],
      ));
    }
    if (searchResult.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
            child: TextField(
          decoration: const InputDecoration(
              hintText: "Please entry the phone you want to search"),
          controller: ctrl,
        )),
        Flexible(
            child: IconButton(
                onPressed: () {
                  searchResult.setParams(ctrl.text);
                  searchResult.next();
                },
                icon: const Icon(Icons.search)))
      ],
    );
  }
}
