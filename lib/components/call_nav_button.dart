import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CallNavButton extends StatelessWidget {
  final String peerID;
  final String peerPhone;

  const CallNavButton(
      {required this.peerID, required this.peerPhone, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          context
              .go("/call", extra: {"peerID": peerID, "peerPhone": peerPhone});
        },
        icon: const Icon(Icons.call));
  }
}
