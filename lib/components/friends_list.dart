import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:webrtc_client/apis/friend.dart';
import 'package:webrtc_client/components/call_nav_button.dart';

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
  final PagingController<int, Friend> _pageCtrl =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pageCtrl.addPageRequestListener((offset) {
      _myFriends(offset);
    });
  }

  Future<void> _myFriends(int offset) async {
    try {
      final friends = await myFriends(
          authToken: widget.authToken, limit: widget.limit, offset: offset);
      if (friends.length < widget.limit) {
        _pageCtrl.appendLastPage(friends);
        return;
      }
      final nextPageKey = offset + friends.length;
      _pageCtrl.appendPage(friends, nextPageKey);
    } catch (error) {
      _pageCtrl.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView(
        pagingController: _pageCtrl,
        builderDelegate: PagedChildBuilderDelegate<Friend>(
            itemBuilder: (context, item, index) => ListTile(
                  title: Text(item.phone),
                  trailing: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.chevron_right),
                          CallNavButton(onPress: () => widget.onCall(item.id)),
                        ]),
                  ),
                  onTap: () {
                    context.go("/chat?to=${item.id}");
                  },
                )));
  }
}
