import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/friend.dart';
import 'package:webrtc_client/blocs/ws.dart';
import 'package:go_router/go_router.dart';

class FriendRequestList extends StatefulWidget {
  final String authToken;

  const FriendRequestList({required this.authToken, super.key});

  @override
  State<StatefulWidget> createState() {
    return _FriendRequestList();
  }
}

class _FriendRequestList extends State<FriendRequestList> {
  late Future<List<FriendRequest>> future;
  late StreamSubscription? sub;

  @override
  void initState() {
    super.initState();
    future = myRequests(widget.authToken);
  }

  @override
  void deactivate() async {
    super.deactivate();
    if (sub != null) {
      await sub!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = BlocProvider.of<WSCubit>(context);
    if (ws.state == null) {
      context.go("/login");
      return Container();
    }
    sub = ws.state!.stream.listen((event) {
      final map = jsonDecode(event);
      if (map["typ"] == "AddFriend") {
        setState(() {
          future = myRequests(widget.authToken);
        });
      }
    });
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(children: [
              Text(snapshot.error.toString()),
              ElevatedButton(
                  onPressed: () {
                    future = myRequests(widget.authToken);
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
                              onPressed: () {
                                rejectRequest(
                                        snapshot.data![i].id, widget.authToken)
                                    .onError((error, stackTrace) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text(error.toString()))));
                              },
                              child: const Text("Reject"),
                            )
                          ])))));
        });
  }
}
