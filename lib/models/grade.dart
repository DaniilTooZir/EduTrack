class Grade {
  final String? id;
  final String lessonId;
  final String studentId;
  final int value;

  Grade({this.id, required this.lessonId, required this.studentId, required this.value});

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id']?.toString(),
      lessonId: map['lessons_id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      value: int.tryParse(map['value'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'lessons_id': lessonId, 'student_id': studentId, 'value': value};
  }
}
