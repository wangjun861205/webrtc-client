import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/apis/session.dart';
import 'package:webrtc_client/blocs/session.dart';
import 'package:webrtc_client/components/call_nav_button.dart';

class SessionItem extends StatelessWidget {
  final Session session;
  final Function(String id) onCall;

  const SessionItem({required this.session, required this.onCall, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: session.unreadCount > 0
          ? Badge.count(
              count: session.unreadCount,
              alignment: Alignment.topLeft,
              backgroundColor: Colors.red,
              child: Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(session.peerPhone)),
            )
          : Text(session.peerPhone),
      subtitle: Text(session.latestContent),
      trailing: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          const Icon(Icons.chevron_right),
          CallNavButton(onPress: () => onCall(session.peerID)),
        ]),
      ),
      onTap: () {
        context.go("/chat?to=${session.peerID}");
      },
    );
  }
}

class SessionList extends StatefulWidget {
  final int limit;
  final String authToken;
  final Function(String id) onCall;

  const SessionList(
      {required this.limit,
      required this.authToken,
      required this.onCall,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return _SessionList();
  }
}

class _SessionList extends State<SessionList> {
  @override
  Widget build(BuildContext context) {
    final sessions = BlocProvider.of<SessionsCubit>(context, listen: true);
    if (sessions.state.error != null) {
      return Center(
          child: Column(
        children: [
          Text(sessions.state.error.toString()),
          ElevatedButton(
              onPressed: () => sessions.next(), child: const Text("Retry"))
        ],
      ));
    }
    if (sessions.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
        itemCount: sessions.state.result.length,
        itemBuilder: (context, index) => SessionItem(
              session: sessions.state.result[index],
              onCall: widget.onCall,
            ));
  }
}