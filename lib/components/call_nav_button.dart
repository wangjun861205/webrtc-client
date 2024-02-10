import 'package:flutter/material.dart';

class CallNavButton extends StatefulWidget {
  final Function() onPress;

  const CallNavButton({required this.onPress, super.key});

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
          widget.onPress();
        },
        icon: const Icon(Icons.call));
  }
}
