import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webrtc_client/main.dart';

enum UserType {
  stranger,
  friend,
  myself,
  requesting,
  requested,
}

class User {
  String id;
  String phone;
  UserType typ;
  String? avatar;

  User(
      {required this.id,
      required this.phone,
      required this.typ,
      required this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json["id"],
        phone: json["phone"],
        typ: () {
          switch (json["typ"] as String) {
            case "Friend":
              return UserType.friend;
            case "Myself":
              return UserType.myself;
            case "Requesting":
              return UserType.requesting;
            case "Requested":
              return UserType.requested;
            default:
              return UserType.stranger;
          }
        }(),
        avatar: json["avatar"]);
  }
}

Future<User?> searchUser(
    {required String authToken, required String phone}) async {
  final resp = await get(
      Uri.parse("http://${Config.backendDomain}/apis/v1/users?phone=$phone"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to get all users: ${resp.body}");
  }
  final json = jsonDecode(resp.body);
  return json != null ? User.fromJson(json) : null;
}

class FriendRequest {
  String id;
  String from;
  String phone;

  FriendRequest({required this.id, required this.from, required this.phone});

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
        id: json["id"], from: json["from"], phone: json["phone"]);
  }
}

Future<List<FriendRequest>> myRequests(String authToken) async {
  final resp = await get(
      Uri.parse("http://${Config.backendDomain}/apis/v1/friends/requests"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to load my requests: ${resp.body}");
  }
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((v) => FriendRequest.fromJson(v))
      .toList();
}

Future<String> addFriend(String friendID, authToken) async {
  final resp = await post(
      Uri.parse("http://${Config.backendDomain}/apis/v1/friends/requests"),
      headers: {"Content-Type": "application/json", "X-Auth-Token": authToken},
      body: jsonEncode({"friend_id": friendID}));
  if (resp.statusCode != 200) {
    throw Exception("failed to add friend: ${resp.body}");
  }
  return jsonDecode(resp.body)["id"];
}

Future<void> acceptRequest(String id, authToken) async {
  final resp = await put(
      Uri.parse(
          "http://${Config.backendDomain}/apis/v1/friends/requests/$id/accept"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to add friend: ${resp.body}");
  }
}

Future<void> rejectRequest(String id, authToken) async {
  final resp = await put(
      Uri.parse(
          "http://${Config.backendDomain}/apis/v1/friends/requests/$id/reject"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to add friend: ${resp.body}");
  }
}

class Friend {
  final String id;
  final String phone;
  final String? avatar;

  const Friend({required this.id, required this.phone, required this.avatar});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(id: json["id"], phone: json["phone"], avatar: json["avatar"]);
  }
}

Future<List<Friend>> myFriends({required String authToken}) async {
  try {
    final resp = await get(
        Uri.parse("http://${Config.backendDomain}/apis/v1/friends"),
        headers: {"X-Auth-Token": authToken});
    if (resp.statusCode != 200) {
      throw Exception(resp.body);
    }
    return (jsonDecode(resp.body) as List<dynamic>)
        .map((v) => Friend.fromJson(v))
        .toList();
  } catch (e) {
    throw Exception("failed to get my friends: ${e.toString()}");
  }
}

Future<int> numOfFriendRequests(String authToken) async {
  final resp = await get(
      Uri.parse(
          "http://${Config.backendDomain}/apis/v1/friends/requests/count"),
      headers: {"X-Auth-Token": authToken});
  if (resp.statusCode != 200) {
    throw Exception("failed to get number of friends requests: ${resp.body}");
  }
  return jsonDecode(resp.body)["count"];
}
