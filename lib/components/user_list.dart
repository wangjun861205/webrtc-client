import 'package:flutter/material.dart';
import 'package:webrtc_client/apis/friend.dart';

class UserList extends StatefulWidget {
  final String authToken;

  const UserList({required this.authToken, super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserList();
  }
}

class _UserList extends State<UserList> {
  Future<User?>? future;
  TextEditingController phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          SizedBox(
              width: 200,
              child: TextField(
                controller: phoneCtrl,
              )),
          ElevatedButton(
              onPressed: () => setState(() {
                    future = searchUser(
                        authToken: widget.authToken, phone: phoneCtrl.text);
                  }),
              child: const Text("Search"))
        ],
      ),
      if (future != null)
        FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return ElevatedButton(
                    onPressed: () => setState(() => future = searchUser(
                        authToken: widget.authToken, phone: phoneCtrl.text)),
                    child: const Text("Refresh"));
              }
              if (!snapshot.hasData) {
                return Container();
              }
              return SizedBox(
                  height: 300,
                  child: Row(children: [
                    SizedBox(width: 300, child: Text(snapshot.data!.id)),
                    SizedBox(width: 200, child: Text(snapshot.data!.phone)),
                    SizedBox(
                        width: 100,
                        child: () {
                          switch (snapshot.data!.typ) {
                            case UserType.stranger:
                              return TextButton(
                                  onPressed: () {
                                    addFriend(
                                            snapshot.data!.id, widget.authToken)
                                        .catchError((e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(e.toString())));
                                      return e.toString();
                                    });
                                  },
                                  child: const Text("Add"));
                            case UserType.friend:
                              return TextButton(
                                  onPressed: () {}, child: const Text("Del"));
                            case UserType.myself:
                              return const Text("Myself");
                            case UserType.requested:
                              return const Text("Requested");
                            case UserType.requesting:
                              return const Text("Requesting");
                          }
                        }())
                  ]));
            })
    ]);
  }
}
