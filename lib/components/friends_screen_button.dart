import 'package:flutter/material.dart';
import 'package:webrtc_client/apis/friend.dart';

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

  @override
  void initState() {
    super.initState();
    future = numOfFriendRequests(widget.authToken);
  }

  @override
  Widget build(BuildContext context) {
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
              IconButton(onPressed: () {}, icon: const Icon(Icons.contacts)),
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
