// Модель для домашнего задания
class Homework {
  final String id;
  final String institutionId;
  final String subjectId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final DateTime createdAt;

  Homework({
    required this.id,
    required this.institutionId,
    required this.subjectId,
    required this.title,
    this.description,
    this.dueDate,
    required this.createdAt,
  });

  factory Homework.fromMap(Map<String, dynamic> map) {
    return Homework(
      id: map['id'] as String,
      institutionId: map['institution_id'] as String,
      subjectId: map['subject_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institution_id': institutionId,
      'subject_id': subjectId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
