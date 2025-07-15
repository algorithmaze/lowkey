
import 'dart:io';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lowkey/chat/message.dart';
import 'package:lowkey/chat/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:lowkey/contacts/user.dart';


import 'package:lowkey/chat/chat.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription<List<Chat>>? _chatsSubscription;

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<SendMessage>((event, emit) async {
      final currentUserId = supabase_flutter.Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) {
        // Handle error: user not logged in
        return;
      }
      if (state is! ChatLoaded) return; // Ensure state is ChatLoaded to get chatId

      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: (state as ChatLoaded).chatId!, // Get chatId from state
        content: event.content,
        senderId: currentUserId,
        createdAt: DateTime.now(),
        selfDestructTimer: event.selfDestructTimer,
      );
      await _chatRepository.sendMessage(newMessage);
    });

    on<LoadMessages>((event, emit) async {
      emit(ChatLoaded(chatId: event.chatId)); // Set chatId in state
      _chatRepository.getMessages(event.chatId).listen((messages) {
        add(_MessagesUpdated(messages));
      });
      // We need to get the other user's ID from the chat ID. This will require a new method in ChatRepository.
      // For now, we'll leave otherUser as null or fetch it later.
      // final otherUser = await _userRepository.getUserProfile(event.chatPartnerId);
      // if (state is ChatLoaded) {
      //   emit((state as ChatLoaded).copyWith(otherUser: otherUser));
      // }
    });

    on<_MessagesUpdated>((event, emit) {
      if (state is ChatLoaded) {
        emit((state as ChatLoaded).copyWith(messages: event.messages));
      }
    });

    on<AddReaction>((event, emit) async {
      await _chatRepository.addReaction(event.messageId, event.reaction);
    });

    on<SendFile>((event, emit) async {
      if (state is! ChatLoaded) return;
      await _chatRepository.sendFile(File(event.filePath), event.fileName, (state as ChatLoaded).chatId!);
    });

    on<DownloadFile>((event, emit) async {
      
      await _chatRepository.downloadFile(event.fileUrl, event.fileName);
    });

    on<ClearChatHistory>((event, emit) async {
      await _chatRepository.clearChatHistory();
      emit(const ChatLoaded(messages: []));
    });

    on<UpdateTypingStatus>((event, emit) async {
      // TODO: Replace with actual other user ID
      await _chatRepository.updateTypingStatus('00000000-0000-0000-0000-000000000000', event.isTyping);
      if (state is ChatLoaded) {
        emit((state as ChatLoaded).copyWith(isTyping: event.isTyping));
      }
    });

    on<UpdateOnlineStatus>((event, emit) async {
      if (state is ChatLoaded) {
        final updatedOtherUser = (state as ChatLoaded).otherUser?.copyWith(
              isOnline: event.isOnline,
              lastSeen: event.lastSeen,
            );
        emit((state as ChatLoaded).copyWith(otherUser: updatedOtherUser));
      }
    });

    on<LoadChats>((event, emit) async {
      emit(ChatLoading());
      _chatsSubscription?.cancel();
      _chatsSubscription = _chatRepository.getChats().listen((chats) {
        add(_ChatsUpdated(chats));
      });
    });

    on<_ChatsUpdated>((event, emit) {
      emit(ChatsLoaded(chats: event.chats));
    });
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}



