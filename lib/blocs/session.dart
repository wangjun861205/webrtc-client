import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webrtc_client/apis/session.dart';
import 'package:webrtc_client/utils.dart';

class SessionsState {
  final List<Session> sessions;
  final int limit;
  final int offset;
  final bool isLoading;
  final Object? error;

  const SessionsState(
      {required this.sessions,
      required this.limit,
      required this.offset,
      required this.isLoading,
      required this.error});
}

class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit({int limit = 20, int offset = 0})
      : super(SessionsState(
            sessions: [],
            limit: limit,
            offset: offset,
            isLoading: false,
            error: null));

  void load() async {
    emit(SessionsState(
        sessions: state.sessions,
        limit: state.limit,
        offset: state.offset,
        isLoading: true,
        error: null));
    try {
      final sessions = await mySessions(
          authToken: (await getAuthToken())!,
          limit: state.limit,
          offset: state.offset);
      emit(SessionsState(
          sessions: sessions,
          limit: state.limit,
          offset: state.limit + state.offset,
          isLoading: false,
          error: false));
    } catch (err) {
      emit(SessionsState(
          sessions: state.sessions,
          limit: state.limit,
          offset: state.offset,
          isLoading: false,
          error: err));
    }
  }
}
