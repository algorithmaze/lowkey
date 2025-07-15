
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lowkey/chat/chat_bloc.dart';
import 'package:lowkey/chat/message.dart';
import 'package:lowkey/core/app_colors.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  final Message message;
  final bool isCurrentUser;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  Timer? _timer;
  int _remainingTime = 0;

  @override
  void initState() {
    super.initState();
    if (widget.message.selfDestructTimer != null) {
      _remainingTime = widget.message.selfDestructTimer!;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime = _remainingTime - 1;
        });
      } else {
        timer.cancel();
        // TODO: Trigger message deletion (e.g., via a Supabase function or a background process)
        
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: widget.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                title: const Text('Add Reaction'),
                actions: <CupertinoActionSheetAction>[
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<ChatBloc>().add(AddReaction(messageId: widget.message.id, reaction: '👍'));
                    },
                    child: const Text('👍'),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<ChatBloc>().add(AddReaction(messageId: widget.message.id, reaction: '❤️'));
                    },
                    child: const Text('❤️'),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<ChatBloc>().add(AddReaction(messageId: widget.message.id, reaction: '😂'));
                    },
                    child: const Text('😂'),
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
          child: Container(
            decoration: BoxDecoration(
              color: widget.isCurrentUser
                  ? AppColors.outgoingMessageBackground
                  : AppColors.incomingMessageBackground,
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.message.fileUrl != null)
                  CupertinoButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(DownloadFile(
                            fileUrl: widget.message.fileUrl!,
                            fileName: widget.message.fileName!,
                          ));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.doc_fill,
                            color: widget.isCurrentUser
                                ? AppColors.outgoingMessageText
                                : AppColors.incomingMessageText),
                        const SizedBox(width: 4.0),
                        Text(
                          widget.message.fileName ?? 'File',
                          style: TextStyle(
                            color: widget.isCurrentUser
                                ? AppColors.outgoingMessageText
                                : AppColors.incomingMessageText,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    widget.message.content,
                    style: TextStyle(
                      color: widget.isCurrentUser
                          ? AppColors.outgoingMessageText
                          : AppColors.incomingMessageText,
                    ),
                  ),
                if (widget.message.selfDestructTimer != null)
                  Text(
                    'Self-destructs in: ${_remainingTime}s',
                    style: const TextStyle(fontSize: 10, color: CupertinoColors.systemRed),
                  ),
                if (widget.message.reactions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.message.reactions.entries.map((entry) {
                        return Text(
                          '${entry.key} ${entry.value}',
                          style: const TextStyle(fontSize: 12),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
