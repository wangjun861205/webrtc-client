import 'package:flutter/material.dart';
import 'package:webrtc_client/apis/me.dart';
import 'package:webrtc_client/main.dart';
import 'package:go_router/go_router.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          logout(AuthToken.token).then((_) => context.go("/login"),
              onError: (err) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(err.toString())));
          });
        },
        child: const Text("Logout"));
  }
}
