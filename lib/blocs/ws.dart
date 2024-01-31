import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WS {
  final Sink sink;
  final Stream stream;

  const WS({required this.sink, required this.stream});
}

class WSCubit extends Cubit<WS?> {
  WSCubit() : super(null);

  Future<void> setWS(WebSocketChannel ws) async {
    if (state != null) {
      state!.sink.close();
    }
    final ctrl = StreamController.broadcast();
    await ctrl.addStream(ws.stream);
    emit(WS(sink: ws.sink, stream: ctrl.stream));
    return;
  }
}

