class Lesson {
  final int id;
  final String scheduleId;
  final String? topic;

  Lesson({required this.id, required this.scheduleId, this.topic});

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(id: map['id'] as int, scheduleId: map['schedule_id'] as String, topic: map['topic'] as String?);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'schedule_id': scheduleId, 'topic': topic};
  }
}
