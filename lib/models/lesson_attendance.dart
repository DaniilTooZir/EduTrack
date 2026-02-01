class LessonAttendance {
  final String? id;
  final String lessonId;
  final String studentId;
  final String? status;

  LessonAttendance({this.id, required this.lessonId, required this.studentId, this.status});

  factory LessonAttendance.fromMap(Map<String, dynamic> map) {
    return LessonAttendance(
      id: map['id']?.toString(),
      lessonId: map['lesson_id']?.toString() ?? '',
      studentId: map['student_id'] as String,
      status: map['status'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'lesson_id': lessonId, 'student_id': studentId, 'status': status};
  }
}
