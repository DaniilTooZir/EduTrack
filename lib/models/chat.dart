class Chat {
  final String id;
  final String type;
  final String? name;
  final String? groupId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chat({
    required this.id,
    required this.type,
    this.name,
    this.groupId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id']?.toString() ?? '',
      type: map['type'] ?? 'direct',
      name: map['name'],
      groupId: map['group_id']?.toString(),
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
      updatedAt:
          map['updated_at'] != null
              ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'group_id': groupId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
