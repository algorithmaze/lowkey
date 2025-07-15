import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lowkey/chat/chat_bloc.dart';
import 'package:lowkey/chat/message_bubble.dart';
import 'package:lowkey/chat/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lowkey/main.dart';
import 'package:lowkey/chat/typing_indicator.dart';
import 'package:lowkey/contacts/user_repository.dart';

class ChatPage extends StatelessWidget {
  final String chatId;
  final String chatPartnerUsername;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.chatPartnerUsername,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatBloc>(
      create: (context) => ChatBloc(
        ChatRepository(Supabase.instance.client, fileService),
      )..add(LoadMessages(chatId)),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoaded) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(chatPartnerUsername),
                    if (state.otherUser != null)
                      Text(
                        state.otherUser!.isOnline
                            ? 'Online'
                            : 'Last seen: ${state.otherUser!.lastSeen?.toLocal().hour.toString().padLeft(2, '0')}:${state.otherUser!.lastSeen?.toLocal().minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                      ),
                  ],
                );
              }
              return Text(chatPartnerUsername);
            },
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                    return ListView.builder(
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isCurrentUser = message.senderId == currentUserId;
                        return MessageBubble(
                          message: message,
                          isCurrentUser: isCurrentUser,
                        );
                      },
                    );
                  }
                  return const Center(child: CupertinoActivityIndicator());
                },
              ),
            ),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoaded && state.isTyping) {
                  return const TypingIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
            _MessageInput(),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  const _MessageInput();

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final TextEditingController _controller = TextEditingController();
  int? _selfDestructTimer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CupertinoTextField(
              controller: _controller,
              placeholder: 'Type a message',
              onChanged: (text) {
                context.read<ChatBloc>().add(UpdateTypingStatus(isTyping: text.isNotEmpty));
              },
            ),
          ),
          CupertinoButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result != null && result.files.single.path != null) {
                context.read<ChatBloc>().add(SendFile(
                      filePath: result.files.single.path!,
                      fileName: result.files.single.name,
                    ));
              }
            },
            child: const Icon(CupertinoIcons.paperclip),
          ),
          CupertinoButton(
            onPressed: () {
              if (!mounted) return;
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                  title: const Text('Self-Destruct Timer'),
                  actions: <CupertinoActionSheetAction>[
                    CupertinoActionSheetAction(
                      onPressed: () {
                        setState(() {
                          _selfDestructTimer = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Off'),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () {
                        setState(() {
                          _selfDestructTimer = 5; // 5 seconds
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('5 Seconds'),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () {
                        setState(() {
                          _selfDestructTimer = 10; // 10 seconds
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('10 Seconds'),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () {
                        setState(() {
                          _selfDestructTimer = 30; // 30 seconds
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('30 Seconds'),
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              );
            },
            child: Icon(
              CupertinoIcons.timer,
              color: _selfDestructTimer != null ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
            ),
          ),
          CupertinoButton(
            onPressed: () {
              context.read<ChatBloc>().add(SendMessage(
                    content: _controller.text,
                    selfDestructTimer: _selfDestructTimer,
                  ));
              _controller.clear();
              setState(() {
                _selfDestructTimer = null;
              });
              context.read<ChatBloc>().add(const UpdateTypingStatus(isTyping: false));
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}