import 'package:edu_track/models/student.dart';

class StudentDebtInfo {
  final Student student;
  final double averageGrade;
  final int pendingHomeworkCount;
  final List<String> pendingHomeworkTitles;

  const StudentDebtInfo({
    required this.student,
    required this.averageGrade,
    required this.pendingHomeworkCount,
    required this.pendingHomeworkTitles,
  });

  bool get hasLowGrade => averageGrade > 0 && averageGrade < 3.0;
  bool get hasPendingHomework => pendingHomeworkCount > 0;
  bool get hasDebts => hasLowGrade || hasPendingHomework;
}
