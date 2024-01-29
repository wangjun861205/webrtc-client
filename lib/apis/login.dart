import 'dart:convert';
import 'package:http/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webrtc_client/apis/common.dart';

class LoginReq {
  final String phone;
  final String password;

  const LoginReq({required this.phone, required this.password});

  Map<String, dynamic> toJson() {
    return {
      "phone": phone,
      "password": password,
    };
  }
}

Future<String> login({required String phone, required String password}) async {
  final resp = await post(Uri.parse("http://$backendDoamin/apis/v1/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(LoginReq(phone: phone, password: password)));
  if (resp.statusCode != 200) {
    throw Exception("failed to login(${resp.statusCode}): ${resp.body}");
  }
  return jsonDecode(resp.body)["token"];
}
