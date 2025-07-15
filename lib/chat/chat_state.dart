
part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final String? chatId;
  final List<Message> messages;
  final User? otherUser;
  final bool isTyping;

  const ChatLoaded({this.chatId, this.messages = const [], this.otherUser, this.isTyping = false});

  @override
  List<Object?> get props => [chatId, messages, otherUser, isTyping];

  ChatLoaded copyWith({
    String? chatId,
    List<Message>? messages,
    User? otherUser,
    bool? isTyping,
  }) {
    return ChatLoaded(
      chatId: chatId ?? this.chatId,
      messages: messages ?? this.messages,
      otherUser: otherUser ?? this.otherUser,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}
