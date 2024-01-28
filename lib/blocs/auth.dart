import 'package:flutter_bloc/flutter_bloc.dart';

typedef AuthToken = String;

class AuthTokenCubit extends Cubit<AuthToken> {
  AuthTokenCubit(String token) : super(token);
}
