import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String?> getAuthToken() =>
    const FlutterSecureStorage().read(key: "AuthToken");

Future<void> putAuthToken(String token) =>
    const FlutterSecureStorage().write(key: "AuthToken", value: token);
