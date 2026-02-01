class GradeComment {
  final String id;
  final String gradeId;
  final String? senderTeacherId;
  final String? senderStudentId;
  final String? message;
  final DateTime timestamp;

  GradeComment({
    required this.id,
    required this.gradeId,
    this.senderTeacherId,
    this.senderStudentId,
    this.message,
    required this.timestamp,
  });

  factory GradeComment.fromMap(Map<String, dynamic> map) {
    return GradeComment(
      id: map['id']?.toString() ?? '',
      gradeId: map['grade_id']?.toString() ?? '',
      senderTeacherId: map['sender_teacher_id']?.toString(),
      senderStudentId: map['sender_students_id']?.toString(),
      message: map['message'] as String?,
      timestamp:
          map['timestamp'] != null ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grade_id': gradeId,
      'sender_teacher_id': senderTeacherId,
      'sender_students_id': senderStudentId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
