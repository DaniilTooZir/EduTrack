import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/teacher.dart';

// Модель для расписания уроков
class Schedule {
  final String id;
  final String institutionId;
  final String subjectId;
  final String groupId;
  final String teacherId;
  final DateTime? date;
  final int weekday;
  final String startTime;
  final String endTime;
  final Subject? subject;
  final Group? group;
  final Teacher? teacher;

  Schedule({
    required this.id,
    required this.institutionId,
    required this.subjectId,
    required this.groupId,
    required this.teacherId,
    this.date,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    this.subject,
    this.group,
    this.teacher,
  });

  String? get subjectName => subject?.name;
  String? get groupName => group?.name;

  String get teacherName {
    if (teacher != null) {
      return '${teacher!.surname} ${teacher!.name}';
    }
    return 'Неизвестно';
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id']?.toString() ?? '',
      institutionId: map['institution_id']?.toString() ?? '',
      subjectId: map['subject_id']?.toString() ?? '',
      groupId: map['group_id']?.toString() ?? '',
      teacherId: map['teacher_id']?.toString() ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) : null,
      weekday: int.tryParse(map['weekday'].toString()) ?? 1,
      startTime: map['start_time']?.toString() ?? '',
      endTime: map['end_time']?.toString() ?? '',
      subject: map['subject'] != null ? Subject.fromMap(map['subject'] as Map<String, dynamic>) : null,
      group: map['group'] != null ? Group.fromMap(map['group'] as Map<String, dynamic>) : null,
      teacher: map['teacher'] != null ? Teacher.fromMap(map['teacher'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institution_id': institutionId,
      'subject_id': subjectId,
      'group_id': groupId,
      'teacher_id': teacherId,
      'date': date?.toIso8601String(),
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
