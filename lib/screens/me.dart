import 'package:flutter/material.dart';
import 'package:webrtc_client/components/avatar_group.dart';

class MeScreen extends StatefulWidget {
  final String authToken;

  const MeScreen({required this.authToken, super.key});
  @override
  State<StatefulWidget> createState() {
    return _MeScreen();
  }
}

class _MeScreen extends State<MeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Me"),
          centerTitle: true,
        ),
        body: Column(
          children: [AvatarGroup(authToken: widget.authToken)],
        ));
  }
}
