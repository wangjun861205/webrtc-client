import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webrtc_client/blocs/chat.dart';
import 'package:webrtc_client/components/video_view.dart';
import 'package:webrtc_client/utils.dart';
import '../message.dart' as message;
import 'package:go_router/go_router.dart';

Future<RTCPeerConnection> _createPeerConnection() async {
  Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ]
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  RTCPeerConnection pc =
      await createPeerConnection(configuration, offerSdpConstraints);

  return pc;
}

_getUserMedia() async {
  final Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
    }
  };

  MediaStream stream =
      await navigator.mediaDevices.getUserMedia(mediaConstraints);

  return stream;
}

class HomeScreen extends StatelessWidget {
  final VideoStateCubit state = VideoStateCubit();
  final FriendsCubit friends = FriendsCubit();
  final WebSocketChannel ws =
      WebSocketChannel.connect(Uri.parse("ws://localhost:8000/apis/v1/ws"));
  RTCPeerConnection? peerConn;
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  HomeScreen({super.key}) {
    _createPeerConnection().then((conn) => peerConn = conn);
    // localRenderer.initialize().then((_) {});
    // remoteRenderer.initialize().then((_) {});
    getAuthToken().then((token) => ws.sink.add(jsonEncode({
          "token": token,
          "to": "server",
          "payload": jsonEncode({"typ": "Greet"})
        })));
    ws.stream.listen((event) {
      final map = jsonDecode(event);
      debugPrint("received: $map");
      switch (map["typ"]) {
        case "Message":
          final payload = jsonDecode(map["payload"]);
          switch (payload["typ"]) {
            case "Offer":
              dynamic offer = jsonDecode(payload["payload"]);
              // String sdp = write(offer["sdp"], null);
              RTCSessionDescription description =
                  RTCSessionDescription(offer["sdp"], offer["type"]);
              peerConn!.setRemoteDescription(description);
              state.set(VideoState.beingCalled);
          }
        case "GreetResponse":
          List<String> fs = (jsonDecode(map["payload"]) as List<dynamic>)
              .map((v) => v as String)
              .toList();
          state.set(VideoState.idle);
          friends.set(fs);
      }
    });
  }

  Future<MediaStream> getLocalStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);
    return stream;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: state),
          BlocProvider.value(value: friends),
          BlocProvider(create: (_) => SelectedFriendCubit()),
        ],
        child: Builder(builder: (context) {
          final state = BlocProvider.of<VideoStateCubit>(context, listen: true);
          final friends = BlocProvider.of<FriendsCubit>(context, listen: true);
          final selectedFriend =
              BlocProvider.of<SelectedFriendCubit>(context, listen: true);

          debugPrint(state.state.toString());
          return Scaffold(
              appBar: AppBar(
                title: const Text("Home"),
                centerTitle: true,
                actions: [
                  TextButton(
                      onPressed: () => context.go("/login"),
                      child: const Text("Login"))
                ],
              ),
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 200,
                        child: VideoView(
                            renderer: localRenderer, key: const Key("local"))),
                    SizedBox(
                        height: 200,
                        child: VideoView(
                            renderer: remoteRenderer,
                            key: const Key("remote"))),
                    SizedBox(
                        width: 600,
                        child: DropdownButton(
                            value: selectedFriend.state,
                            onChanged: (item) => selectedFriend.set(item ?? ""),
                            items: friends.state
                                .map((f) => DropdownMenuItem(
                                    key: Key(f), value: f, child: Text(f)))
                                .toList())),
                    state.state == VideoState.idle
                        ? ElevatedButton(
                            onPressed: () async {
                              final localStream = await getLocalStream();
                              peerConn!.addStream(localStream);
                              await localRenderer.initialize();
                              localRenderer.srcObject = localStream;
                              RTCSessionDescription description =
                                  await peerConn!
                                      .createOffer({"offerToReceiveVideo": 1});
                              // final session = parse(description.sdp.toString());
                              await peerConn!.setLocalDescription(description);
                              state.set(VideoState.offering);
                              ws.sink.add(jsonEncode(message.Message(
                                  token: (await getAuthToken())!,
                                  to: selectedFriend.state!,
                                  payload: jsonEncode(message.Payload(
                                      typ: "Offer",
                                      payload:
                                          jsonEncode(description.toMap()))))));
                            },
                            child: const Text("Offer"))
                        : Container()
                  ]));
        }));
  }
}
