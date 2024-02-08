import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/blocs/ws.dart';
import 'package:webrtc_client/screens/call.dart';
import 'package:webrtc_client/screens/callee.dart';
import 'package:webrtc_client/screens/chat.dart';
import 'package:webrtc_client/screens/friends.dart';
import 'package:webrtc_client/screens/home.dart';
import 'package:webrtc_client/screens/login.dart';
import 'package:webrtc_client/screens/me.dart';
import 'package:webrtc_client/screens/signup.dart';
import 'package:webrtc_client/screens/video.dart';
import 'package:webrtc_client/utils.dart';
import './components/video_view.dart';

class Config {
  static get backendDomain {
    return dotenv.env["BACKEND_DOMAIN"];
  }
}

class WS {
  static Sink? _sink;
  static Stream? _stream;

  static setWS(String authToken) {
    _sink?.close();
    final ws = WebSocketChannel.connect(
        Uri.parse("ws://${Config.backendDomain}/ws?auth_token=$authToken"));
    final ctrl = StreamController.broadcast();
    ctrl.addStream(ws.stream);
    _sink = ws.sink;
    _stream = ctrl.stream;
  }

  static Stream getOrCreateStream(String authToken) {
    if (_stream == null) {
      setWS(authToken);
    }
    return _stream!;
  }

  static Sink getOrCreateSink(String authToken) {
    if (_stream == null) {
      setWS(authToken);
    }
    return _sink!;
  }
}

class AuthToken {
  static String? _token;

  static get token => _token;
  static set token(t) => _token = t;
}

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  late GoRouter route;

  MyApp({super.key}) {
    route = GoRouter(
        routes: [
          GoRoute(
              path: "/",
              builder: (context, state) =>
                  HomeScreen(authToken: AuthToken.token)),
          GoRoute(path: "/login", builder: (context, state) => LoginScreen()),
          GoRoute(path: "/signup", builder: (context, state) => SignupScreen()),
          GoRoute(
              path: "/friends",
              builder: (context, state) => FriendsScreen(
                    authToken: AuthToken.token,
                  )),
          GoRoute(
              path: "/chat",
              builder: (context, state) {
                return ChatScreen(
                    authToken: AuthToken.token,
                    to: state.uri.queryParameters["to"]!);
              }),
          GoRoute(
              path: "/me",
              builder: (context, state) {
                return MeScreen(authToken: AuthToken.token);
              }),
          GoRoute(
              path: "/call/:calleeID",
              builder: (context, state) {
                return CallScreen(
                    authToken: AuthToken.token,
                    calleeID: state.pathParameters["calleeID"]!);
              }),
          GoRoute(
              path: "/callee/:callID",
              builder: (context, state) {
                return CalleeScreen(
                  authToken: AuthToken.token,
                  callID: state.pathParameters["callID"]!,
                  description:
                      (state.extra! as Map<String, dynamic>)["description"],
                );
              }),
          GoRoute(
              path: "/video",
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return VideoScreen(
                    authToken: AuthToken.token,
                    localStream: extra["localStream"],
                    peerConn: extra["peerConn"]);
              })
        ],
        redirect: (context, state) async {
          if (state.matchedLocation == "/login" ||
              state.matchedLocation == "/signup") {
            return state.matchedLocation;
          }
          final authToken = await getAuthToken();
          if (authToken == null) {
            return "/login";
          }
          AuthToken.token = authToken;
          return null;
        });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: route,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  final WebSocketChannel ws =
      WebSocketChannel.connect(Uri.parse("ws://localhost:8000/ws"));

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _localVideoRenderer = RTCVideoRenderer();
  final _remoteVideoRenderer = RTCVideoRenderer();
  final sdpController = TextEditingController();

  bool _offer = false;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  initRenderer() async {
    await _localVideoRenderer.initialize();
    await _remoteVideoRenderer.initialize();
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

    _localVideoRenderer.srcObject = stream;
    return stream;
  }

  _createPeerConnecion() async {
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

    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream!);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        print(json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMLineIndex,
        }));
      }
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteVideoRenderer.srcObject = stream;
    };

    return pc;
  }

  void _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection!.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    print(json.encode(session));
    _offer = true;

    _peerConnection!.setLocalDescription(description);
  }

  void _createAnswer() async {
    RTCSessionDescription description =
        await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp.toString());
    print(json.encode(session));

    _peerConnection!.setLocalDescription(description);
  }

  void _setRemoteDescription() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode(jsonString);

    String sdp = write(session, null);

    RTCSessionDescription description =
        RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print(description.toMap());

    await _peerConnection!.setRemoteDescription(description);
  }

  void _addCandidate() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode(jsonString);
    print(session['candidate']);
    dynamic candidate = RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection!.addCandidate(candidate);
  }

  @override
  void initState() {
    initRenderer();
    _createPeerConnecion().then((pc) {
      _peerConnection = pc;
    });
    // _getUserMedia();
    super.initState();
  }

  @override
  void dispose() async {
    await _localVideoRenderer.dispose();
    sdpController.dispose();
    super.dispose();
  }

  SizedBox videoRenderers() => SizedBox(
        height: 210,
        child: Row(children: [
          Flexible(
            child: VideoView(
                renderer: _localVideoRenderer, key: const Key("local")),
          ),
          Flexible(
            child: VideoView(
                renderer: _remoteVideoRenderer, key: const Key("remote")),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            videoRenderers(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextField(
                      controller: sdpController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      maxLength: TextField.noMaxLength,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _createOffer,
                      child: const Text("Offer"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: _createAnswer,
                      child: const Text("Answer"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: _setRemoteDescription,
                      child: const Text("Set Remote Description"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: _addCandidate,
                      child: const Text("Set Candidate"),
                    ),
                  ],
                )
              ],
            ),
          ],
        ));
  }
}
