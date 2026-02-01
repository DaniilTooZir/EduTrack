class LessonComment {
  final String? id;
  final String lessonId;
  final String? senderTeacherId;
  final String? senderStudentId;
  final String? message;
  final DateTime timestamp;

  LessonComment({
    this.id,
    required this.lessonId,
    this.senderTeacherId,
    this.senderStudentId,
    this.message,
    required this.timestamp,
  });

  factory LessonComment.fromMap(Map<String, dynamic> map) {
    return LessonComment(
      id: map['id']?.toString(),
      lessonId: map['lesson_id']?.toString() ?? '',
      senderTeacherId: map['sender_teacher_id']?.toString(),
      senderStudentId: map['sender_student_id']?.toString(),
      message: map['message'] as String?,
      timestamp:
          map['timestamp'] != null ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lesson_id': lessonId,
      'sender_teacher_id': senderTeacherId,
      'sender_student_id': senderStudentId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
