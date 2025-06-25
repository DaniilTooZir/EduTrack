// Модель для расписания уроков
class Schedule {
  final String id;
  final String institutionId;
  final String subjectId;
  final String groupId;
  final int weekday;
  final String startTime;
  final String endTime;
  final String? subjectName;
  final String? groupName;

  Schedule({
    required this.id,
    required this.institutionId,
    required this.subjectId,
    required this.groupId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    this.subjectName,
    this.groupName,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    final subject = map['subject'] as Map<String, dynamic>?;
    final group = map['group'] as Map<String, dynamic>?;
    return Schedule(
      id: map['id'] as String,
      institutionId: map['institution_id'] as String,
      subjectId: map['subject_id'] as String,
      groupId: map['group_id'] as String,
      weekday: map['weekday'] as int,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      subjectName: subject != null ? subject['name'] as String? : null,
      groupName: group != null ? group['name'] as String? : null,
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
