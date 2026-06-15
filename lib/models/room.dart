class Room {
  final String id;
  final String name;
  final String institutionId;

  Room({required this.id, required this.name, required this.institutionId});

  factory Room.fromMap(Map<String, dynamic> map) {
    final id = map['id']?.toString();
    if (id == null || id.isEmpty) throw FormatException('Room.fromMap: missing id');
    return Room(
      id: id,
      name: map['name']?.toString() ?? '',
      institutionId: map['institution_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {if (id.isNotEmpty) 'id': id, 'name': name, 'institution_id': institutionId};
  }

  Room copyWith({String? id, String? name, String? institutionId}) {
    return Room(id: id ?? this.id, name: name ?? this.name, institutionId: institutionId ?? this.institutionId);
  }
}
