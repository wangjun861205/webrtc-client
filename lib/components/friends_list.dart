import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:webrtc_client/apis/session.dart';
import 'package:webrtc_client/blocs/chat.dart';
import 'package:webrtc_client/blocs/session.dart';
import 'package:webrtc_client/components/call_nav_button.dart';
import 'package:webrtc_client/screens/chat.dart';

class SessionItem extends StatelessWidget {
  final String authToken;
  final Function(String id) onCall;

  const SessionItem({required this.authToken, required this.onCall, super.key});

  @override
  Widget build(BuildContext context) {
    final session = BlocProvider.of<SessionCubit>(context);
    return ListTile(
      title: session.state.unreadCount > 0
          ? Badge.count(
              count: session.state.unreadCount,
              alignment: Alignment.topLeft,
              backgroundColor: Colors.red,
              child: Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(session.state.peerPhone)),
            )
          : Text(session.state.peerPhone),
      trailing: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          const Icon(Icons.chevron_right),
          CallNavButton(onPress: () => onCall(session.state.peerID)),
        ]),
      ),
      onTap: () {
        final msgs = BlocProvider.of<ChatMessagesCubit>(context);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BlocProvider.value(
                value: msgs,
                child: ChatScreen(
                    authToken: authToken, to: session.state.peerID))));
        // context.go("/chat?to=${item.id}");
      },
    );
  }
}

class FriendsList extends StatefulWidget {
  final int limit;
  final String authToken;
  final Function(String id) onCall;

  const FriendsList(
      {required this.limit,
      required this.authToken,
      required this.onCall,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return _FriendsList();
  }
}

class _FriendsList extends State<FriendsList> {
  final PagingController<int, Session> _pageCtrl =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pageCtrl.addPageRequestListener((offset) {
      _myFriends(offset);
    });
    super.initState();
  }

  Future<void> _myFriends(int offset) async {
    try {
      final sessions = await mySessions(
          authToken: widget.authToken, limit: widget.limit, offset: offset);
      if (sessions.length < widget.limit) {
        _pageCtrl.appendLastPage(sessions);
        return;
      }
      final nextPageKey = offset + sessions.length;
      _pageCtrl.appendPage(sessions, nextPageKey);
    } catch (error) {
      _pageCtrl.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView(
      pagingController: _pageCtrl,
      builderDelegate: PagedChildBuilderDelegate<Session>(
          itemBuilder: (context, item, index) => BlocProvider(
              create: (_) =>
                  SessionCubit(authToken: widget.authToken, session: item),
              child: SessionItem(
                authToken: widget.authToken,
                onCall: widget.onCall,
              ))),
    );
  }
}
