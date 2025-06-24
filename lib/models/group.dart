class Group {
  final String? id;
  final String name;
  final String institutionId;
  final DateTime? createdAt;

  Group({
    this.id,
    required this.name,
    required this.institutionId,
    this.createdAt,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      institutionId: map['institution_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'institution_id': institutionId,
    };
  }
}