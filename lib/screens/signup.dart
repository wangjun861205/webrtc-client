import 'package:flutter/material.dart';
import 'package:webrtc_client/apis/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webrtc_client/apis/signup.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatelessWidget {
  late TextEditingController phoneCtrl;
  late TextEditingController passwordCtrl;

  SignupScreen({super.key}) {
    phoneCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
  }

  Widget input(
      {required TextEditingController controller,
      required Widget label,
      required String hintText,
      bool obscureText = false}) {
    return ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300,
          minWidth: 200,
        ),
        child: TextField(
          obscureText: true,
          controller: controller,
          decoration: InputDecoration(label: label, hintText: hintText),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signup"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          input(
              controller: phoneCtrl,
              label: const Text("Phone"),
              hintText: "Please enter your phone"),
          input(
              controller: passwordCtrl,
              label: const Text("Password"),
              hintText: "Please enter your password",
              obscureText: true),
          ElevatedButton(
              onPressed: () {
                signup(phone: phoneCtrl.text, password: passwordCtrl.text).then(
                    (token) {
                  const FlutterSecureStorage()
                      .write(key: "AuthToken", value: token)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Successfully signup")));
                    context.go("/login");
                  });
                }, onError: (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                });
              },
              child: const Text("Signup"))
        ]),
      ),
    );
  }
}
