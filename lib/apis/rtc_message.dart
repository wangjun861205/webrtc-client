import 'dart:convert';

import 'package:http/http.dart';
import 'package:webrtc_client/main.dart';

class RTCMessage {
  final String to;
  final String typ;
  final String payload;

  const RTCMessage(
      {required this.to, required this.typ, required this.payload});
}

Future<void> sendRTCMessage(
    {required String authToken, required RTCMessage msg}) async {
  final resp = await post(
      Uri.parse("http://${Config.backendDomain}/apis/v1/rtc_messages"),
      headers: {"X-Auth-Token": authToken},
      body: jsonEncode(msg));
  if (resp.statusCode != 200) {
    throw Exception(resp.body);
  }
}
