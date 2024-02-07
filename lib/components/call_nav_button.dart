import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CallNavButton extends StatefulWidget {
  final String calleeID;

  const CallNavButton({required this.calleeID, super.key});

  @override
  State<StatefulWidget> createState() {
    return _CallNavButton();
  }
}

class _CallNavButton extends State<CallNavButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          context.go("/call/${widget.calleeID}");
        },
        icon: const Icon(Icons.call));
  }
}
