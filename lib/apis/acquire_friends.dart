import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webrtc_client/apis/common.dart';
import 'package:webrtc_client/utils.dart';

Future<List<String>> acquireFriends() async {
  final token = await getAuthToken();
  final resp = await get(Uri.parse("$baseURL/friends"),
      headers: {"X-Auth-Token": token!});
  if (resp.statusCode != 200) {
    throw Exception("failed to get friends: ${resp.body}");
  }
  debugPrint(resp.body);
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((v) => v as String)
      .toList();
}
