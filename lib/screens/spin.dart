import 'package:flutter/material.dart';

class SpinScreen extends StatelessWidget {
  const SpinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Error"), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()));
  }
}
