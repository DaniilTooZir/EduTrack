import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/lesson_attendance.dart';

class JournalCell {
  final String studentId;
  final String lessonId;
  final Grade? grade;
  final LessonAttendance? attendance;

  const JournalCell({required this.studentId, required this.lessonId, this.grade, this.attendance});
}
