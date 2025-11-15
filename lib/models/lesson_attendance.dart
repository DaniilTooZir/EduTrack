class LessonAttendance {
  final int? id;
  final int lessonId;
  final String studentId;
  final String? status;

  LessonAttendance({this.id, required this.lessonId, required this.studentId, this.status});

  factory LessonAttendance.fromMap(Map<String, dynamic> map) {
    return LessonAttendance(
      id: map['id'] as int,
      lessonId: map['lesson_id'] as int,
      studentId: map['student_id'] as String,
      status: map['status'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'lesson_id': lessonId, 'student_id': studentId, 'status': status};
  }
}
