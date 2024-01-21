import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final dynamic error;

  const ErrorScreen({required this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Error"), centerTitle: true),
        body: Center(
            child: Column(
          children: [
            Text(error.toString()),
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Go Back"))
          ],
        )));
  }
}
