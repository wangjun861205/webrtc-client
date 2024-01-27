import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webrtc_client/apis/acquire_friends.dart';
import 'package:webrtc_client/blocs/chat.dart';
import 'package:webrtc_client/components/video_view.dart';
import 'package:webrtc_client/screens/error.dart';
import 'package:webrtc_client/screens/spin.dart';
import 'package:webrtc_client/utils.dart';
import '../message.dart' as message;
import 'package:go_router/go_router.dart';

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

class HomeScreen extends StatefulWidget {
  final WebSocketChannel ws;
  const HomeScreen({required this.ws, super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> {
  RTCPeerConnection? peerConn;
  List<RTCIceCandidate> candidates = [];
  RTCVideoRenderer localRenderer = RTCVideoRenderer()..initialize();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer()..initialize();
  VideoState status = VideoState.idle;
  String? selectedFriend;
  List<String> friends = [];

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
    pc.onTrack = (event) {
      remoteRenderer.srcObject = event.streams[0];
      setState(() {});
    };

    pc.onIceCandidate = (RTCIceCandidate candidate) =>
        setState(() => candidates.add(candidate));
    return pc;
  }

  @override
  initState() {
    super.initState();
    _createPeerConnection().then((conn) => peerConn = conn);
    widget.ws.stream.listen((event) {
      final map = jsonDecode(event);
      // debugPrint(map.toString());
      switch (map["typ"]) {
        case "Message":
          final content = jsonDecode(map["data"]["content"]);
          switch (content["typ"]) {
            case "Offer":
              dynamic offer = jsonDecode(content["payload"]);
              RTCSessionDescription description =
                  RTCSessionDescription(offer["sdp"], offer["type"]);
              peerConn!.setRemoteDescription(description);
              peerConn!.createAnswer().then((answer) {
                peerConn!.setLocalDescription(answer);
                widget.ws.sink.add(jsonEncode({
                  "Message": {
                    "to": map["data"]["from"],
                    "content":
                        jsonEncode({"typ": "Answer", "payload": answer.toMap()})
                  }
                }));
              });
            case "IceCandidate":
              final data = content["payload"];
              final candidate = data["iceCandidate"]["candidate"];
              final sdpMid = data["iceCandidate"]["id"];
              final sdpMLineIndex = data["iceCandidate"]["label"];
              peerConn!.addCandidate(
                  RTCIceCandidate(candidate, sdpMid, sdpMLineIndex));
            case "Answer":
              debugPrint(content.toString());
              peerConn!
                  .setRemoteDescription(RTCSessionDescription(
                      content["payload"]["sdp"], content["payload"]["type"]))
                  .then((_) {
                for (RTCIceCandidate candidate in candidates) {
                  widget.ws.sink.add(jsonEncode({
                    "Message": {
                      "to": map["data"]["from"],
                      "content": jsonEncode({
                        "typ": "IceCandidate",
                        "payload": {
                          "calleeId": "widget.calleeId",
                          "iceCandidate": {
                            "id": candidate.sdpMid,
                            "label": candidate.sdpMLineIndex,
                            "candidate": candidate.candidate
                          }
                        }
                      })
                    }
                  }));
                }
              });
          }
        case "Greet":
          setState(() {
            friends.add(map["data"] as String);
          });
        case "AcquireFriends":
          setState(() {
            friends =
                (map["data"] as List<dynamic>).map((v) => v as String).toList();
          });
      }
      widget.ws.sink.add(jsonEncode("Online"));
    });
  }

  _HomeScreen();

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
        body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          localRenderer.srcObject != null
              ? SizedBox(
                  height: 200,
                  child: VideoView(
                      renderer: localRenderer, key: const Key("local")))
              : Container(),
          remoteRenderer.srcObject != null
              ? SizedBox(
                  height: 200,
                  child: VideoView(
                      renderer: remoteRenderer, key: const Key("remote")))
              : Container(),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
                width: 600,
                child: DropdownButton(
                    value: selectedFriend,
                    onChanged: (item) => setState(() {
                          selectedFriend = item;
                        }),
                    items: friends
                        .map((f) => DropdownMenuItem(
                            key: Key(f), value: f, child: Text(f)))
                        .toList())),
            ElevatedButton(
                onPressed: () =>
                    widget.ws.sink.add(jsonEncode("AcquireFriends")),
                child: const Text("Refresh")),
          ]),
          status == VideoState.idle
              ? ElevatedButton(
                  onPressed: () async {
                    final localStream = await getLocalStream();
                    localStream.getVideoTracks().forEach((track) {
                      peerConn!.addTrack(track, localStream);
                    });
                    setState(() {});
                    // peerConn!.addStream(localStream);
                    // await localRenderer.initialize();
                    localRenderer.srcObject = localStream;
                    RTCSessionDescription description =
                        await peerConn!.createOffer(
                            // {"offerToReceiveVideo": 1}
                            );
                    await peerConn!.setLocalDescription(description);
                    setState(() {
                      status = VideoState.offering;
                    });
                    widget.ws.sink.add(jsonEncode({
                      "Message": {
                        "to": selectedFriend!,
                        "content": jsonEncode(message.Payload(
                            typ: "Offer",
                            payload: jsonEncode(description.toMap())))
                      }
                    }));
                  },
                  child: const Text("Offer"))
              : Container()
        ]));
  }
}
