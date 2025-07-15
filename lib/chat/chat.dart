import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String id;
  final String user1Id;
  final String user2Id;
  final String lastMessage;
  final DateTime updatedAt;

  const Chat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String,
      lastMessage: json['last_message'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message': lastMessage,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, user1Id, user2Id, lastMessage, updatedAt];
}
