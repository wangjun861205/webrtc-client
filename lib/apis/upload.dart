import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:webrtc_client/main.dart';

Future<String> upload(String authToken, filename, List<int> data) async {
  final req = MultipartRequest(
      "POST", Uri.parse("http://${Config.backendDomain}/apis/v1/uploads"));
  req.headers.addAll(
      {"X-Auth-Token": authToken, "Content-Type": "multipart/form-data"});
  req.files.add(MultipartFile.fromBytes("file", data, filename: filename));
  final resp = await req.send();
  final body = utf8.decode(await resp.stream.toBytes());
  if (resp.statusCode != HttpStatus.ok) {
    throw Exception("failed to upload file: $body");
  }
  final json = jsonDecode(body);
  return json["ids"][0];
}
