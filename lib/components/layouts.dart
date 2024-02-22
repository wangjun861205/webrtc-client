import 'package:flutter/material.dart';
import 'package:webrtc_client/main.dart';

class WithBottomNavigationBar extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final int selectedIndex;

  const WithBottomNavigationBar(
      {required this.body,
      required this.selectedIndex,
      this.appBar,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
            BottomNavigationBarItem(
                icon: Icon(Icons.contacts), label: "Contacts"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
          ],
          onTap: (i) {
            switch (i) {
              case 0:
                route.go("/");
              case 1:
                route.go("/friends");
              case 2:
                route.go("/me");
            }
          },
          currentIndex: selectedIndex,
          selectedItemColor: Colors.blue[500],
          unselectedItemColor: Colors.grey,
        ));
  }
}
