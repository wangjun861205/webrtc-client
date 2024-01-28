import 'package:flutter/material.dart';
import 'package:webrtc_client/apis/friend.dart';

class FriendRequestList extends StatefulWidget {
  final String authToken;
  final Future<List<FriendRequest>> Function() nextFuture;

  const FriendRequestList(
      {required this.authToken, required this.nextFuture, super.key});

  @override
  State<StatefulWidget> createState() {
    return _FriendRequestList();
  }
}

class _FriendRequestList extends State<FriendRequestList> {
  late Future<List<FriendRequest>> future;

  @override
  void initState() {
    super.initState();
    future = widget.nextFuture();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(children: [
              Text(snapshot.error.toString()),
              ElevatedButton(
                  onPressed: () {
                    future = widget.nextFuture();
                    setState(() {});
                  },
                  child: const Text("Refresh"))
            ]);
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          return SizedBox(
              height: 400,
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) => ListTile(
                      title: Text(snapshot.data![i].from),
                      trailing: SizedBox(
                          width: 300,
                          child: Row(children: [
                            TextButton(
                                onPressed: () {
                                  acceptRequest(snapshot.data![i].id,
                                          widget.authToken)
                                      .onError((error, stackTrace) =>
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content:
                                                      Text(error.toString()))));
                                },
                                child: const Text("Accept")),
                            TextButton(
                              onPressed: () {},
                              child: const Text("Reject"),
                            )
                          ])))));
        });
  }
}
