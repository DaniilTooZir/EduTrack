import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/subject.dart';
// Модель для расписания уроков
class Schedule {
  final String id;
  final String institutionId;
  final String subjectId;
  final String groupId;
  final String teacherId;
  final DateTime? date;
  final String startTime;
  final String endTime;
  final Subject? subject;
  final Group? group;

  Schedule({
    required this.id,
    required this.institutionId,
    required this.subjectId,
    required this.groupId,
    required this.teacherId,
    this.date,
    required this.startTime,
    required this.endTime,
    this.subject,
    this.group,
  });

  int get weekday => date?.weekday ?? 1;
  String? get subjectName => subject?.name;
  String? get groupName => group?.name;

  factory Schedule.fromMap(Map<String, dynamic> map) {
    final subjectMap = map['subject'] as Map<String, dynamic>?;
    final groupMap = map['group'] as Map<String, dynamic>?;
    return Schedule(
      id: map['id']?.toString() ?? '',
      institutionId: map['institution_id']?.toString() ?? '',
      subjectId: map['subject_id']?.toString() ?? '',
      groupId: map['group_id']?.toString() ?? '',
      teacherId: map['teacher_id']?.toString() ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) : null,
      startTime: map['start_time']?.toString() ?? '',
      endTime: map['end_time']?.toString() ?? '',
      subject: subjectMap != null ? Subject.fromMap(subjectMap) : null,
      group: groupMap != null ? Group.fromMap(groupMap) : null,
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
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
