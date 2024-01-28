import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webrtc_client/apis/common.dart';
import 'package:webrtc_client/utils.dart';

enum UserType {
  stranger,
  friend,
  myself,
}

class User {
  String id;
  UserType typ;

  User({required this.id, required this.typ});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json["id"],
        typ: json["typ"] == "Friend"
            ? UserType.friend
            : json["typ"] == "Myself"
                ? UserType.myself
                : UserType.stranger);
  }
}

Future<List<User>> allUsers(String authToken) async {
  final resp = await get(Uri.parse("$baseURL/users"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to get all users: ${resp.body}");
  }
  debugPrint(resp.body);
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json.map((v) => User.fromJson(v)).toList();
}

class FriendRequest {
  String id;
  String from;
  String to;

  FriendRequest({required this.id, required this.from, required this.to});

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(id: json["id"], from: json["from"], to: json["to"]);
  }
}

Future<List<FriendRequest>> myRequests(String authToken) async {
  final resp = await get(Uri.parse("$baseURL/friends/requests"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to load my requests: ${resp.body}");
  }
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((v) => FriendRequest.fromJson(v))
      .toList();
}

Future<String> addFriend(String friendID, authToken) async {
  final resp = await post(Uri.parse("$baseURL/friends/requests"),
      headers: {"Content-Type": "application/json", "X-Auth-Token": authToken},
      body: jsonEncode({"friend_id": friendID}));
  if (resp.statusCode != 200) {
    throw Exception("failed to add friend: ${resp.body}");
  }
  return jsonDecode(resp.body)["id"];
}

Future<void> acceptRequest(String id, authToken) async {
  final resp = await put(Uri.parse("$baseURL/friends/requests/$id/accept"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to add friend: ${resp.body}");
  }
}

Future<List<String>> myFriends(String authToken) async {
  final resp = await get(Uri.parse("$baseURL/friends"));
  if (resp.statusCode != 200) {
    throw Exception("failed to get my friends: ${resp.body}");
  }
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((v) => v as String)
      .toList();
}
