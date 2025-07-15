class User {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  User({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}