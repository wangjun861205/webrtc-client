import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/friend.dart';
import 'package:webrtc_client/blocs/friend.dart';
import 'package:webrtc_client/main.dart';

class AddFriendButton extends StatelessWidget {
  const AddFriendButton({super.key});

  @override
  Widget build(BuildContext context) {
    final searchResult = BlocProvider.of<FriendSearchResultCubit>(context);
    return ElevatedButton(
        onPressed: () {
          addFriend(searchResult.state.result!.id, AuthToken.token).then((_) {
            searchResult.setResult(User(
                id: searchResult.state.result!.id,
                phone: searchResult.state.result!.phone,
                typ: UserType.requesting,
                avatar: searchResult.state.result!.avatar));
          }, onError: (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          });
        },
        child: const Text("Add"));
  }
}

class FriendSearchResult extends StatelessWidget {
  final String authToken;
  const FriendSearchResult({required this.authToken, super.key});

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

    if (searchResult.state.result == null) {
      return const Align(child: Text("No result"));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        searchResult.state.result!.avatar != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(
                    "http://${Config.backendDomain}/apis/v1/uploads/${searchResult.state.result!.avatar!}",
                    headers: {"X-Auth-Token": authToken}),
              )
            : const CircleAvatar(),
        Text(searchResult.state.result!.phone),
        searchResult.state.result!.typ == UserType.friend
            ? const Text("Already added")
            : searchResult.state.result!.typ == UserType.myself
                ? const Text("Myself")
                : searchResult.state.result!.typ == UserType.requested
                    ? const Text("Requested")
                    : searchResult.state.result!.typ == UserType.requesting
                        ? const Text("Requesting")
                        : const AddFriendButton()
      ],
    );
  }
}
