import 'dart:io';

import 'package:lowkey/chat/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lowkey/core/file_service.dart';

class ChatRepository {
  final SupabaseClient _supabaseClient;
  final FileService _fileService;

  ChatRepository(this._supabaseClient, this._fileService);

  Stream<List<Message>> getMessages(String chatId) {
    return _supabaseClient
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((maps) => maps.map((map) => Message.fromJson(map)).toList());
  }

  Future<void> sendMessage(Message message) async {
    await _supabaseClient.from('messages').insert(message.toJson());
  }

  Future<void> sendFile(File file, String fileName, String chatId) async {
    final currentUserId = _supabaseClient.auth.currentUser?.id;
    if (currentUserId == null) {
      // Handle error: user not logged in
      return;
    }

    final fileUrl = await _fileService.uploadFile(
      file,
      'chat_files', // Supabase bucket name
      '$currentUserId/${DateTime.now().millisecondsSinceEpoch}_$fileName',
    );

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      content: 'File: $fileName',
      senderId: currentUserId,
      createdAt: DateTime.now(),
      fileUrl: fileUrl,
      fileName: fileName,
    );
    await sendMessage(message);
  }

  Future<void> addReaction(String messageId, String reaction) async {
    final response = await _supabaseClient
        .from('messages')
        .select('reactions')
        .eq('id', messageId)
        .single();

    if (response.isNotEmpty) {
      final currentReactions = Map<String, int>.from(response['reactions'] ?? {});
      currentReactions.update(reaction, (value) => value + 1, ifAbsent: () => 1);

      await _supabaseClient
          .from('messages')
          .update({'reactions': currentReactions})
          .eq('id', messageId);
    }
  }

  Future<void> downloadFile(String fileUrl, String fileName) async {
    try {
      await _fileService.downloadFile(fileUrl);
      // In a real app, save the file to a temporary directory and provide the path to the user.
      await _fileService.deleteFile(fileUrl);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> clearChatHistory() async {
    await _supabaseClient.from('messages').delete().neq('id', '0'); // Delete all messages
  }

  Future<void> updateTypingStatus(String userId, bool isTyping) async {
    await _supabaseClient.from('profiles').update({'is_typing': isTyping}).eq('id', userId);
  }

  Future<String?> getChatIdForUsers(String userId1, String userId2) async {
    final response = await _supabaseClient
        .from('chats')
        .select('id')
        .or('user1_id.eq.$userId1,user2_id.eq.$userId2')
        .or('user1_id.eq.$userId2,user2_id.eq.$userId1')
        .limit(1)
        .single();
    if (response.isEmpty) {
      return null;
    }
    return response['id'] as String?;
  }

  Future<String> createChat(String user1Id, String user2Id) async {
    final response = await _supabaseClient.from('chats').insert({
      'user1_id': user1Id,
      'user2_id': user2Id,
    }).select('id').single();
    return response['id'] as String;
  }

  Stream<List<Chat>> getChats() {
    final currentUserId = _supabaseClient.auth.currentUser?.id;
    if (currentUserId == null) return Stream.value([]);

    return _supabaseClient
        .from('chats')
        .stream(primaryKey: ['id'])
        .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId')
        .order('updated_at', ascending: false)
        .map((maps) => maps.map((map) => Chat.fromJson(map)).toList());
  }
}
