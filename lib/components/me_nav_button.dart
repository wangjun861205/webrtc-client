import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MeNavButton extends StatefulWidget {
  const MeNavButton({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MeNavButton();
  }
}

class _MeNavButton extends State<MeNavButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          context.go("/me");
        },
        icon: const Icon(Icons.person));
  }
}
