// Модель для статуса домашнего задания
class HomeworkStatus {
  final String id;
  final String homeworkId;
  final String studentId;
  final bool isCompleted;
  final DateTime updatedAt;
  final String? studentComment;
  final String? fileUrl;
  final String? fileName;

  HomeworkStatus({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.isCompleted,
    required this.updatedAt,
    this.studentComment,
    this.fileUrl,
    this.fileName,
  });

  factory HomeworkStatus.fromMap(Map<String, dynamic> map) {
    return HomeworkStatus(
      id: map['id']?.toString() ?? '',
      homeworkId: map['homework_id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      isCompleted: map['is_completed'] == true,
      updatedAt:
          map['updated_at'] != null
              ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
      studentComment: map['student_comment']?.toString(),
      fileUrl: map['file_url']?.toString(),
      fileName: map['file_name']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'homework_id': homeworkId,
      'student_id': studentId,
      'is_completed': isCompleted,
      'updated_at': updatedAt.toIso8601String(),
      'student_comment': studentComment,
      'file_url': fileUrl,
      'file_name': fileName,
    };
  }

  HomeworkStatus copyWith({
    String? id,
    String? homeworkId,
    String? studentId,
    bool? isCompleted,
    DateTime? updatedAt,
    String? studentComment,
    String? fileUrl,
    String? fileName,
  }) {
    return HomeworkStatus(
      id: id ?? this.id,
      homeworkId: homeworkId ?? this.homeworkId,
      studentId: studentId ?? this.studentId,
      isCompleted: isCompleted ?? this.isCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
      studentComment: studentComment ?? this.studentComment,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
    );
  }
}
