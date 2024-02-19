import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/apis/me.dart';
import 'package:webrtc_client/blocs/chat.dart';
import 'package:webrtc_client/blocs/me.dart';
import 'package:webrtc_client/blocs/rtc.dart';
import 'package:webrtc_client/screens/call.dart';
import 'package:webrtc_client/screens/callee.dart';
import 'package:webrtc_client/screens/chat.dart';
import 'package:webrtc_client/screens/error.dart';
import 'package:webrtc_client/screens/friends.dart';
import 'package:webrtc_client/screens/home.dart';
import 'package:webrtc_client/screens/login.dart';
import 'package:webrtc_client/screens/me.dart';
import 'package:webrtc_client/screens/search_friend.dart';
import 'package:webrtc_client/screens/signup.dart';
import 'package:webrtc_client/screens/video.dart';
import 'package:webrtc_client/screens/welcome.dart';
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
      debugPrint(event);
      final json = jsonDecode(event);
      if (json["typ"] == "RTC") {
        final payload = jsonDecode(json["payload"]);
        if (payload["rtcType"] == "offer") {
          route.go("/callee", extra: {
            "peerID": json["from"],
            "peerPhone": json["phone"],
            "sdp": payload["sdp"],
            "rtcType": payload["rtcType"]
          });
          return;
        }
      }
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
    delete(Uri.parse("http://${Config.backendDomain}/me"),
        headers: {"X-Auth-Token": AuthToken.token});
  }
}

class AuthToken {
  static String? _token;

  static get token => _token;
  static set token(t) => _token = t;
}

Future<void> _onBackgroundMessage(RemoteMessage message) async {
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
  final fcmToken = await FirebaseMessaging.instance
      .getToken(vapidKey: kIsWeb ? dotenv.get("VAPID") : null);
  if (fcmToken == null) {
    throw Exception("cannot get FCM token");
  }
  await putFCMToken(fcmToken);
  final authToken = await getAuthToken();
  if (authToken != null) {
    try {
      await verifyAuthToken(authToken);
    } catch (err) {
      route.go("/login");
      return;
    }
    await updateFCMToken(authToken, fcmToken);
  }
  FirebaseMessaging.onMessage.listen((event) {
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
    initialLocation: "/welcome",
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
            return BlocProvider(
              create: (_) => MeCubit(),
              child: ChatScreen(
                  authToken: AuthToken.token,
                  to: state.uri.queryParameters["to"]!),
            );
          }),
      GoRoute(
          path: "/me",
          builder: (context, state) {
            return MeScreen(authToken: AuthToken.token);
          }),
      GoRoute(
          path: "/call",
          builder: (context, state) {
            final extra = state.extra as Map<String, String>;
            final peerID = extra["peerID"]!;
            final peerPhone = extra["peerPhone"]!;
            debugPrint("peerID: $peerID, peerPhone: $peerPhone");
            return BlocProvider(
                create: (_) => RTCCubit(peerID: peerID, peerPhone: peerPhone),
                child: const CallScreen());
          }),
      GoRoute(
          path: "/callee",
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final peerID = extra["peerID"]!;
            final peerPhone = extra["peerPhone"]!;
            final sdp = extra["sdp"]!;
            final rtcType = extra["rtcType"]!;
            final description = RTCSessionDescription(sdp, rtcType);
            return BlocProvider(
                create: (_) => RTCCubit(
                    peerID: peerID,
                    peerPhone: peerPhone,
                    remoteDescription: description),
                child: const CalleeScreen());
          }),
      // GoRoute(
      //     path: "/video",
      //     builder: (context, state) {
      //       final extra = state.extra as Map<String, dynamic>;
      //       return VideoScreen(
      //         authToken: AuthToken.token,
      //         rtc: extra["rtc"],
      //       );
      //     }),
      GoRoute(
          path: "/search_friends",
          builder: (context, state) {
            return SearchFriendScreen(authToken: AuthToken.token);
          }),
      GoRoute(
          path: "/error",
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return ErrorScreen(error: extra["error"], retry: extra["retry"]);
          }),
      GoRoute(
          path: "/welcome",
          builder: (context, state) {
            return WelcomeScreen();
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
