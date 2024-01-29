import 'package:flutter/material.dart';
import 'package:webrtc_client/apis/friend.dart';

class FriendDropdown extends StatefulWidget {
  final String authToken;
  final void Function(String id) onChanged;

  const FriendDropdown(
      {required this.authToken, required this.onChanged, super.key});

  @override
  State<StatefulWidget> createState() {
    return _FriendDropdown();
  }
}

class _FriendDropdown extends State<FriendDropdown> {
  String? selected;
  late Future<List<String>> future;

  @override
  void initState() {
    super.initState();
    future = myFriends(widget.authToken);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFriends(widget.authToken),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(
              children: [
                Text(snapshot.error.toString()),
                TextButton(
                    onPressed: () => setState(() {
                          future = myFriends(widget.authToken);
                        }),
                    child: const Text("Retry"))
              ],
            );
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return DropdownButton(
              value: selected,
              items: snapshot.data!
                  .map((f) => DropdownMenuItem(key: Key(f), child: Text(f)))
                  .toList(),
              onChanged: (v) {
                setState(() => selected = v);
                widget.onChanged(v as String);
              });
        });
  }
}
