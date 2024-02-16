import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/friend.dart';
import 'package:webrtc_client/blocs/friend.dart';
import 'package:webrtc_client/blocs/ws.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/main.dart';

class AcceptButton extends StatelessWidget {
  final String id;

  const AcceptButton({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    final reqs = BlocProvider.of<FriendRequestsCubit>(context, listen: true);
    return TextButton(
        onPressed: () {
          acceptRequest(id, AuthToken.token).then((_) {
            reqs.setResult(reqs.state.result..removeWhere((r) => r.id == id));
          }, onError: (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          });
        },
        child: const Text("Accept"));
  }
}

class RejectButton extends StatelessWidget {
  final String id;

  const RejectButton({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    final reqs = BlocProvider.of<FriendRequestsCubit>(context, listen: true);
    return TextButton(
        onPressed: () {
          rejectRequest(id, AuthToken.token).then((_) {
            reqs.setResult(reqs.state.result..removeWhere((r) => r.id == id));
          }, onError: (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          });
        },
        child: const Text("Reject"));
  }
}

class FriendRequestList extends StatelessWidget {
  const FriendRequestList({super.key});

  @override
  Widget build(BuildContext context) {
    final reqs = BlocProvider.of<FriendRequestsCubit>(context, listen: true);
    if (reqs.state.error != null) {
      return Center(
          child: Column(children: [
        Text(reqs.state.error.toString()),
        ElevatedButton(
            onPressed: () => reqs.next(), child: const Text("Refresh"))
      ]));
    }
    if (reqs.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reqs.state.result.isEmpty) {
      return const Center(child: Text("No friend request"));
    }

    return ListView.builder(
        itemCount: reqs.state.result.length,
        itemBuilder: (context, i) => ListTile(
            title: Text(reqs.state.result[i].phone),
            trailing: SizedBox(
                width: 300,
                child: Row(children: [
                  AcceptButton(id: reqs.state.result[i].id),
                  RejectButton(id: reqs.state.result[i].id),
                ]))));
  }
}
