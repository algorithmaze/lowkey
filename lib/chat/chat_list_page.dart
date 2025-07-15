import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lowkey/chat/chat_bloc.dart';
import 'package:lowkey/chat/chat.dart';
import 'package:lowkey/chat/chat_page.dart';
import 'package:lowkey/contacts/user.dart' as local_user;

import 'package:lowkey/contacts/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChats());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Chats'),
      ),
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatsLoaded) {
            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                final currentUserId = context.read<SupabaseClient>().auth.currentUser?.id;
                final otherUserId =
                    chat.user1Id == currentUserId ? chat.user2Id : chat.user1Id;
                return FutureBuilder<local_user.User?>(
                  future: context.read<UserRepository>().getUserProfileById(otherUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CupertinoActivityIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Error loading user');
                    }
                    final local_user.User otherUser = snapshot.data!;
                    return CupertinoListTile(
                      title: Text(otherUser.username),
                      subtitle: Text(chat.lastMessage),
                      leading: CircleAvatar(
                        backgroundImage: otherUser.avatarUrl != null
                            ? NetworkImage(otherUser.avatarUrl!)
                            : null,
                        child: otherUser.avatarUrl == null
                            ? const Icon(CupertinoIcons.person)
                            : null,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => ChatPage(
                              chatId: chat.id,
                              chatPartnerUsername: otherUser.username,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          }
          return const Center(child: CupertinoActivityIndicator());
        },
      ),
    );
  }
}
