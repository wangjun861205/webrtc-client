import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AvatarGroup extends StatefulWidget {
  final String authToken;

  const AvatarGroup({required this.authToken});

  @override
  State<StatefulWidget> createState() {
    return _AvatarGroup();
  }
}

class _AvatarGroup extends State<AvatarGroup> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          child: Image.network(),
        )
      ],
    );
  }
}
