class Lesson {
  final String? id;
  final String scheduleId;
  final String? topic;
  final String attendanceStatus;

  Lesson({this.id, required this.scheduleId, this.topic, required this.attendanceStatus});

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id']?.toString(),
      scheduleId: map['schedule_id']?.toString() ?? '',
      topic: map['topic']?.toString(),
      attendanceStatus: map['attendance_status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {'schedule_id': scheduleId, 'topic': topic, 'attendance_status': attendanceStatus};
  }
}
