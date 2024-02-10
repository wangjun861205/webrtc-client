import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
            leading: IconButton(
              onPressed: () => context.go("/"),
              icon: const Icon(Icons.chevron_left),
            )),
        body: Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [AvatarGroup(authToken: widget.authToken)],
          ),
        ));
  }
}
