class ChatMember {
  final String id;
  final String chatId;
  final String userId;
  final String userRole;
  final DateTime joinedAt;

  ChatMember({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.userRole,
    required this.joinedAt,
  });

  factory ChatMember.fromMap(Map<String, dynamic> map) {
    return ChatMember(
      id: map['id']?.toString() ?? '',
      chatId: map['chat_id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      userRole: map['user_role'] ?? 'student',
      joinedAt:
          map['joined_at'] != null ? DateTime.tryParse(map['joined_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'user_id': userId,
      'user_role': userRole,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
