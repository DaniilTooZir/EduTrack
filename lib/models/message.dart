class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderRole;
  final String? content;
  final String? fileUrl;
  final String? fileName;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderRole,
    this.content,
    this.fileUrl,
    this.fileName,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id']?.toString() ?? '',
      chatId: map['chat_id']?.toString() ?? '',
      senderId: map['sender_id']?.toString() ?? '',
      senderRole: map['sender_role'] ?? '',
      content: map['content'],
      fileUrl: map['file_url'],
      fileName: map['file_name'],
      isRead: map['is_read'] ?? false,
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_role': senderRole,
      'content': content,
      'file_url': fileUrl,
      'file_name': fileName,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
