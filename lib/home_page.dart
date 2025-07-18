
import 'package:flutter/cupertino.dart';


import 'package:lowkey/chat/chat_list_page.dart';
import 'package:lowkey/contacts/contacts_page.dart';
import 'package:lowkey/settings/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            activeIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_fill),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings_solid),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            switch (index) {
              case 0:
                return const ChatListPage();
              case 1:
                return const ContactsPage();
              case 2:
                return const SettingsPage();
              default:
                return const ChatListPage();
            }
          },
        );
      },
    );
  }
}
