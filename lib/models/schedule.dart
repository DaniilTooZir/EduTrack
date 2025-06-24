// Модель для расписания уроков
class Schedule {
  final String id;
  final String institutionId;
  final String subjectId;
  final String groupId;
  final int weekday;
  final String startTime;
  final String endTime;

  Schedule({
    required this.id,
    required this.institutionId,
    required this.subjectId,
    required this.groupId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as String,
      institutionId: map['institution_id'] as String,
      subjectId: map['subject_id'] as String,
      groupId: map['group_id'] as String,
      weekday: map['weekday'] as int,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institution_id': institutionId,
      'subject_id': subjectId,
      'group_id': groupId,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
