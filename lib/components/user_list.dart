import 'package:flutter/material.dart';
import 'package:webrtc_client/apis/friend.dart';

class UserList extends StatefulWidget {
  final Future<List<User>> Function() nextFuture;
  final String authToken;

  const UserList(
      {required this.nextFuture, required this.authToken, super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserList();
  }
}

class _UserList extends State<UserList> {
  late Future<List<User>> future;

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
            return ElevatedButton(
                onPressed: () => setState(() => future = widget.nextFuture()),
                child: const Text("Refresh"));
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          return SizedBox(
              height: 300,
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) => ListTile(
                      title: Text(snapshot.data![i].id),
                      trailing: SizedBox(
                          width: 100,
                          child: snapshot.data![i].typ == UserType.stranger
                              ? TextButton(
                                  onPressed: () {
                                    addFriend(snapshot.data![i].id,
                                            widget.authToken)
                                        .catchError((e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(e.toString())));
                                      return e.toString();
                                    });
                                  },
                                  child: const Text("Add"))
                              : snapshot.data![i].typ == UserType.friend
                                  ? TextButton(
                                      onPressed: () {},
                                      child: const Text("Del"))
                                  : const Text("Myself")))));
        });
  }
}
