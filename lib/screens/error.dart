import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final dynamic error;
  final void Function() retry;

  const ErrorScreen({required this.error, required this.retry, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Error"), centerTitle: true),
        body: Center(
            child: Column(
          children: [
            Text(error.toString()),
            ElevatedButton(onPressed: retry, child: const Text("Retry"))
          ],
        )));
  }
}
