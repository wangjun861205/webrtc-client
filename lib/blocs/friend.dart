import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/friend.dart';
import 'package:webrtc_client/main.dart';

class FriendsState {
  List<Friend> friends;
  bool isLoading;
  Object? error;

  FriendsState({required this.friends, required this.isLoading, this.error});
}

class FriendsCubit extends Cubit<FriendsState> {
  final String authToken;
  late StreamSubscription wsSub;
  FriendsCubit({required this.authToken})
      : super(FriendsState(friends: [], isLoading: false)) {
    wsSub = WS.getOrCreateStream(authToken).listen((event) {
      final json = jsonDecode(event);
      if (json["typ"] != "Accept") {
        return;
      }
      add(Friend(
          id: json["data"]["id"],
          phone: json["data"]["phone"],
          avatar: json["data"]["avatar"]));
    });
  }

  @override
  Future<void> close() {
    wsSub.cancel();
    return super.close();
  }

  void load() async {
    emit(FriendsState(friends: state.friends, isLoading: true));
    try {
      final friends = await myFriends(authToken: authToken);
      emit(FriendsState(friends: friends, isLoading: false));
    } catch (e) {
      emit(FriendsState(friends: state.friends, isLoading: false, error: e));
    }
  }

  void add(Friend friend) {
    final friends = state.friends;
    final i = friends
        .indexWhere((element) => element.phone.compareTo(friend.phone) == 1);
    friends.insert(i, friend);
    emit(FriendsState(
        friends: friends, isLoading: state.isLoading, error: state.error));
  }
}
