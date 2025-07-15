import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lowkey/contacts/add_friend_screen.dart';
import 'package:lowkey/contacts/friends_bloc.dart';
import 'package:lowkey/chat/chat_page.dart';
import 'package:lowkey/chat/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:lowkey/contacts/user_repository.dart';
import 'package:lowkey/contacts/user.dart';


class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  int _selectedSegment = 0; // 0 for Friends, 1 for Requests

  @override
  void initState() {
    super.initState();
    context.read<FriendsBloc>().add(LoadFriends());
    context.read<FriendsBloc>().add(LoadPendingRequests());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: CupertinoSlidingSegmentedControl<int>(
          groupValue: _selectedSegment,
          onValueChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedSegment = newValue;
              });
            }
          },
          children: const <int, Widget>{
            0: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Friends'),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Requests'),
            ),
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (context) => const AddFriendScreen()),
            );
          },
          child: const Icon(CupertinoIcons.person_add),
        ),
      ),
      child: BlocConsumer<FriendsBloc, FriendsState>(
        listener: (context, state) {
          if (state is FriendRequestAcceptedWithChat) {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Friend Request Accepted!'),
                content: Text('You are now friends with ${state.chatPartnerUsername}.'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Start Chatting'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Dismiss dialog
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => ChatPage(
                            chatId: state.chatId,
                            chatPartnerUsername: state.chatPartnerUsername,
                          ),
                        ),
                      );
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('Later'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FriendsLoading) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (_selectedSegment == 0) {
            // Display Friends
            if (state is FriendsLoaded) {
              return ListView.builder(
                itemCount: state.friends.length,
                itemBuilder: (context, index) {
                  final friend = state.friends[index];
                  return CupertinoListTile(
                    title: Text(friend.username),
                    leading: CircleAvatar(
                      backgroundImage: friend.avatarUrl != null
                          ? NetworkImage(friend.avatarUrl!)
                          : null,
                      child: friend.avatarUrl == null
                          ? const Icon(CupertinoIcons.person)
                          : null,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton(
                          onPressed: () async {
                            final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                            if (currentUserId == null) return;
                            final chatId = await context.read<ChatRepository>().getChatIdForUsers(currentUserId, friend.id);
                            if (!mounted) return;
                            if (chatId != null) {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => ChatPage(chatId: chatId, chatPartnerUsername: friend.username),
                                ),
                              );
                            }
                          },
                          child: const Icon(CupertinoIcons.chat_bubble_2_fill),
                        ),
                        CupertinoButton(
                          onPressed: () {
                            // TODO: Implement call with friend
                          },
                          child: const Icon(CupertinoIcons.phone_fill),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is FriendsError) {
              _showErrorDialog(context, state.message);
              return const Center(child: Text('No friends yet.'));
            }
            return const Center(child: Text('No friends yet.'));
          } else {
            // Display Requests
            if (state is PendingRequestsLoaded) {
              if (state.requests.isEmpty) {
                return const Center(child: Text('No pending requests.'));
              }
              return ListView.builder(
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return CupertinoListTile(
                    title: FutureBuilder<User?>(
                      future: context.read<UserRepository>().getUserProfile(request.senderId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading...');
                        } else if (snapshot.hasError) {
                          return const Text('Error');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          return Text('Request from ${snapshot.data!.username}');
                        } else {
                          return const Text('Request from Unknown User');
                        }
                      },
                    ),
                    trailing: BlocBuilder<FriendsBloc, FriendsState>(
                      builder: (context, state) {
                        if (state is FriendsLoading) {
                          return const CupertinoActivityIndicator();
                        }
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoButton(
                              onPressed: () {
                                context.read<FriendsBloc>().add(AcceptFriendRequest(requestId: request.id));
                              },
                              child: const Icon(CupertinoIcons.check_mark_circled_solid, color: CupertinoColors.activeGreen),
                            ),
                            CupertinoButton(
                              onPressed: () {
                                context.read<FriendsBloc>().add(RejectFriendRequest(requestId: request.id));
                              },
                              child: const Icon(CupertinoIcons.clear_circled_solid, color: CupertinoColors.destructiveRed),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            } else if (state is FriendsError) {
              _showErrorDialog(context, state.message);
              return const Center(child: Text('Loading requests...'));
            }
            return const Center(child: Text('Loading requests...'));
          }
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
