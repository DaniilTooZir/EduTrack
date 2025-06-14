// Модель для расписания уроков
class Schedule {
  final String id;
  final String institutionId;
  final String subjectId;
  final int weekday; // 0 = воскресенье, 6 = суббота
  final String startTime; // формат: HH:mm:ss
  final String endTime;   // формат: HH:mm:ss
  final String classGroup;

  Schedule({
    required this.id,
    required this.institutionId,
    required this.subjectId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.classGroup,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as String,
      institutionId: map['institution_id'] as String,
      subjectId: map['subject_id'] as String,
      weekday: map['weekday'] as int,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      classGroup: map['class_group'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institution_id': institutionId,
      'subject_id': subjectId,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
      'class_group': classGroup,
    };
  }
}
