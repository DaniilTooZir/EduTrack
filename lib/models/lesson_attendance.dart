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
      studentId: map['student_id']?.toString() ?? '',
      status: map['status']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'lesson_id': lessonId,
      'student_id': studentId,
      'status': status,
    };
  }

  LessonAttendance copyWith({String? id, String? lessonId, String? studentId, String? status}) {
    return LessonAttendance(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
    );
  }
}
