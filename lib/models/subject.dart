// Модель для предметов
class Subject {
  final String id;
  final String name;
  final String institutionId;
  final String teacherId;
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.institutionId,
    required this.teacherId,
    required this.createdAt,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as String,
      name: map['name'] as String,
      institutionId: map['institution_id'] as String,
      teacherId: map['teacher_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'institution_id': institutionId,
      'teacher_id': teacherId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
