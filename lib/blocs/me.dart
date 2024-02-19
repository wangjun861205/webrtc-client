import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/me.dart';
import 'package:webrtc_client/main.dart';

class Me {
  final String id;
  final String phone;
  final String? avatar;

  const Me({required this.id, required this.phone, required this.avatar});

  factory Me.fromJson(Map<String, dynamic> json) {
    return Me(id: json["id"], phone: json["phone"], avatar: json["avatar"]);
  }
}

class MeState {
  final Me? me;
  final bool isLoading;
  final Object? error;

  const MeState({this.me, required this.isLoading, this.error});
}

class MeCubit extends Cubit<MeState> {
  MeCubit() : super(const MeState(isLoading: true)) {
    me(AuthToken.token).then((me) {
      if (me == null) {
        route.go("/login");
        return;
      }
      emit(MeState(me: me, isLoading: false));
    }, onError: (err) {
      emit(MeState(isLoading: false, error: err));
    });
  }
}
