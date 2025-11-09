class Grade {
  final int id;
  final int lessonId;
  final String studentId;
  final int value;

  Grade({required this.id, required this.lessonId, required this.studentId, required this.value});

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'] as int,
      lessonId: map['lessons_id'] as int,
      studentId: map['student_id'] as String,
      value: map['value'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'lessons_id': lessonId, 'student_id': studentId, 'value': value};
  }
}
