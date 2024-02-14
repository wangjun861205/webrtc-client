import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/apis/me.dart';
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
import 'package:firebase_messaging/firebase_messaging.dart';
import './components/video_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Config {
  static get backendDomain {
    return dotenv.env["BACKEND_DOMAIN"];
  }
}

class WS {
  static WebSocketChannel? _ws;
  static StreamController? _ctrl;

  static setWS(String authToken) {
    _ws = WebSocketChannel.connect(
        Uri.parse("ws://${Config.backendDomain}/ws?auth_token=$authToken"));
    _ctrl = _ctrl ?? StreamController.broadcast();
    _ws!.stream.listen((event) {
      _ctrl!.add(event);
    });
  }

  static Stream getOrCreateStream(String authToken) {
    if (_ctrl == null || _ws?.closeCode != null) {
      setWS(authToken);
    }
    return _ctrl!.stream;
  }

  static Sink getOrCreateSink(String authToken) {
    if (_ws == null || _ws?.closeCode != null) {
      setWS(authToken);
    }
    return _ws!.sink;
  }

  static close() {
    _ws!.sink.close();
  }
}

class AuthToken {
  static String? _token;

  static get token => _token;
  static set token(t) => _token = t;
}

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  debugPrint(
      "===================got notification===============: ${message.category}");
  route.go("/");
}

initFCM() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  debugPrint('User granted permission: ${settings.authorizationStatus}');
  final fcmToken = await FirebaseMessaging.instance
      .getToken(vapidKey: kIsWeb ? dotenv.get("VAPID") : null);
  if (fcmToken == null) {
    throw Exception("cannot get FCM token");
  }
  await putFCMToken(fcmToken);
  final authToken = await getAuthToken();
  if (authToken != null) {
    await updateFCMToken(authToken, fcmToken);
  }
  FirebaseMessaging.onMessage.listen((event) {
    debugPrint(
        "===================got notification===============: ${event.messageId}");
    route.go("/");
  });
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  FirebaseMessaging.instance.onTokenRefresh.listen((event) {
    if (AuthToken.token != null) {
      updateFCMToken(AuthToken.token!, fcmToken);
    }
  });
}

void main() async {
  await dotenv.load(fileName: ".env");
  await initFCM();
  runApp(const MyApp());
}

final route = GoRouter(
    routes: [
      GoRoute(
          path: "/",
          builder: (context, state) => HomeScreen(authToken: AuthToken.token)),
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
          path: "/call",
          builder: (context, state) {
            return CallScreen(
                authToken: AuthToken.token,
                rtc: (state.extra as Map<String, dynamic>)["rtc"]);
          }),
      GoRoute(
          path: "/callee",
          builder: (context, state) {
            return CalleeScreen(
              authToken: AuthToken.token,
              rtc: (state.extra as Map<String, dynamic>)["rtc"],
            );
          }),
      GoRoute(
          path: "/video",
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return VideoScreen(
              authToken: AuthToken.token,
              rtc: extra["rtc"],
            );
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  _onStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden ||
            AppLifecycleState.paused ||
            AppLifecycleState.detached ||
            AppLifecycleState.inactive:
        WS.close();
      default:
        if (AuthToken.token == null) {
          context.go("/login");
          return;
        }
        WS.setWS(AuthToken.token!);
    }
  }

  @override
  void initState() {
    AppLifecycleListener(onStateChange: _onStateChange);
    super.initState();
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
