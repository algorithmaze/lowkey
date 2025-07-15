
import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String chatId;
  final String content;
  final String senderId;
  final DateTime createdAt;
  final Uint8List? encryptedContent;
  final Uint8List? nonce;
  final Map<String, int> reactions;
  final String? fileUrl;
  final String? fileName;
  final int? selfDestructTimer; // in seconds

  const Message({
    required this.id,
    required this.chatId,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.encryptedContent,
    this.nonce,
    this.reactions = const {},
    this.fileUrl,
    this.fileName,
    this.selfDestructTimer,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      content: json['content'] as String,
      senderId: json['sender_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      encryptedContent: json['encrypted_content'] != null
          ? base64Decode(json['encrypted_content'] as String)
          : null,
      nonce: json['nonce'] != null
          ? base64Decode(json['nonce'] as String)
          : null,
      reactions: Map<String, int>.from(json['reactions'] ?? {}),
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      selfDestructTimer: json['self_destruct_timer'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'content': content,
      'sender_id': senderId,
      'created_at': createdAt.toIso8601String(),
      'encrypted_content':
          encryptedContent != null ? base64Encode(encryptedContent!) : null,
      'nonce': nonce != null ? base64Encode(nonce!) : null,
      'reactions': reactions,
      'file_url': fileUrl,
      'file_name': fileName,
      'self_destruct_timer': selfDestructTimer,
    };
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        content,
        senderId,
        createdAt,
        encryptedContent,
        nonce,
        reactions,
        fileUrl,
        fileName,
        selfDestructTimer,
      ];

  Message copyWith({
    String? id,
    String? chatId,
    String? content,
    String? senderId,
    DateTime? createdAt,
    Uint8List? encryptedContent,
    Uint8List? nonce,
    Map<String, int>? reactions,
    String? fileUrl,
    String? fileName,
    int? selfDestructTimer,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      encryptedContent: encryptedContent ?? this.encryptedContent,
      nonce: nonce ?? this.nonce,
      reactions: reactions ?? this.reactions,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      selfDestructTimer: selfDestructTimer ?? this.selfDestructTimer,
    );
  }
}
