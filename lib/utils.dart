import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String?> getAuthToken() =>
    const FlutterSecureStorage().read(key: "AuthToken");

Future<void> putAuthToken(String token) async {
  return await const FlutterSecureStorage()
      .write(key: "AuthToken", value: token);
}
