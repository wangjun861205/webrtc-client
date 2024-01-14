import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  late TextEditingController emailCtrl;
  late TextEditingController passwordCtrl;

  LoginScreen({super.key}) {
    emailCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
  }

  Widget input(
      {required TextEditingController controller,
      required Widget label,
      required String hintText}) {
    return ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300,
          minWidth: 200,
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(label: label, hintText: hintText),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Column(children: [
        input(
            controller: emailCtrl,
            label: const Text("Email"),
            hintText: "Please enter your email"),
        input(
            controller: passwordCtrl,
            label: const Text("Password"),
            hintText: "Please enter your email")
      ]),
    );
  }
}
