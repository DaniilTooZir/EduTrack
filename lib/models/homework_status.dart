// Модель для статуса домашнего задания
class HomeworkStatus {
  final String id;
  final String homeworkId;
  final String studentId;
  final bool isCompleted;
  final DateTime updatedAt;

  HomeworkStatus({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.isCompleted,
    required this.updatedAt,
  });

  factory HomeworkStatus.fromMap(Map<String, dynamic> map) {
    return HomeworkStatus(
      id: map['id'] as String,
      homeworkId: map['homework_id'] as String,
      studentId: map['student_id'] as String,
      isCompleted: map['is_completed'] as bool,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'homework_id': homeworkId,
      'student_id': studentId,
      'is_completed': isCompleted,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
