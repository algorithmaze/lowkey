
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lowkey/core/app_lock_service.dart';
import 'package:lowkey/chat/chat_bloc.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appLockService = context.watch<AppLockService>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          children: <Widget>[
            CupertinoListSection(
              header: const Text('PRIVACY'),
              children: <CupertinoListTile>[
                CupertinoListTile(
                  title: const Text('App Lock'),
                  trailing: FutureBuilder<bool>(
                    future: appLockService.isPasscodeSet(),
                    builder: (context, snapshot) {
                      return CupertinoSwitch(
                        value: snapshot.data ?? false,
                        onChanged: (bool value) async {
                          if (value) {
                            // Prompt for new passcode
                            // For now, just set a dummy passcode
                            await appLockService.setPasscode('1234');
                          } else {
                            await appLockService.removePasscode();
                          }
                          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                          appLockService.notifyListeners(); // Force rebuild
                        },
                      );
                    },
                  ),
                  onTap: () {},
                ),
                CupertinoListTile(
                  title: const Text('Clear Chat History'),
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                        title: const Text('Clear Chat History'),
                        content: const Text('Are you sure you want to clear all chat history?'),
                        actions: <CupertinoDialogAction>[
                          CupertinoDialogAction(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              context.read<ChatBloc>().add(ClearChatHistory());
                              Navigator.pop(context);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
