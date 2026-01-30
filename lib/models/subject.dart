// Модель для предметов
class Subject {
  final String id;
  final String name;
  final String institutionId;
  final DateTime createdAt;

  Subject({required this.id, required this.name, required this.institutionId, required this.createdAt});

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      institutionId: map['institution_id']?.toString() ?? '',
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'institution_id': institutionId, 'created_at': createdAt.toIso8601String()};
  }
}
