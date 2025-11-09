class Group {
  final String? id;
  final String name;
  final String institutionId;
  final DateTime? createdAt;

  Group({this.id, required this.name, required this.institutionId, this.createdAt});

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      institutionId: map['institution_id']?.toString() ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'institution_id': institutionId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
