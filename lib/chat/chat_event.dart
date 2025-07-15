
part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String content;
  final int? selfDestructTimer;

  const SendMessage({required this.content, this.selfDestructTimer});

  @override
  List<Object> get props => [content, selfDestructTimer ?? 0];
}

class LoadMessages extends ChatEvent {
  final String chatId;

  const LoadMessages(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class _MessagesUpdated extends ChatEvent {
  final List<Message> messages;

  const _MessagesUpdated(this.messages);

  @override
  List<Object> get props => [messages];
}

class AddReaction extends ChatEvent {
  final String messageId;
  final String reaction;

  const AddReaction({required this.messageId, required this.reaction});

  @override
  List<Object> get props => [messageId, reaction];
}

class SendFile extends ChatEvent {
  final String filePath;
  final String fileName;

  const SendFile({required this.filePath, required this.fileName});

  @override
  List<Object> get props => [filePath, fileName];
}

class DownloadFile extends ChatEvent {
  final String fileUrl;
  final String fileName;

  const DownloadFile({required this.fileUrl, required this.fileName});

  @override
  List<Object> get props => [fileUrl, fileName];
}

class ClearChatHistory extends ChatEvent {}

class UpdateTypingStatus extends ChatEvent {
  final bool isTyping;

  const UpdateTypingStatus({required this.isTyping});

  @override
  List<Object> get props => [isTyping];
}

class UpdateOnlineStatus extends ChatEvent {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;

  const UpdateOnlineStatus({required this.userId, required this.isOnline, this.lastSeen});

  @override
  List<Object?> get props => [userId, isOnline, lastSeen];
}

