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
      id: map['id']?.toString() ?? '',
      homeworkId: map['homework_id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      isCompleted: map['is_completed'] ?? false,
      updatedAt:
          map['updated_at'] != null
              ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
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
