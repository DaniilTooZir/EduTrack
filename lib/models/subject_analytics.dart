import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/subject.dart';

class SubjectAnalytics {
  final Subject subject;
  final List<Grade> grades;
  final double averageGrade;

  final List<({DateTime date, int value, String? gradeId})> gradeSeries;
  const SubjectAnalytics({
    required this.subject,
    required this.grades,
    required this.averageGrade,
    required this.gradeSeries,
  });

  factory SubjectAnalytics.fromGrades(
    Subject subject,
    List<Grade> allGrades,
    Map<String, String> lessonSubjectMap, {
    Map<String, DateTime>? lessonDateMap,
  }) {
    final filtered = allGrades.where((g) => lessonSubjectMap[g.lessonId] == subject.id).toList();
    final List<({DateTime date, int value, String? gradeId})> series;
    if (lessonDateMap != null) {
      series =
          filtered
              .where((g) => lessonDateMap.containsKey(g.lessonId))
              .map((g) => (date: lessonDateMap[g.lessonId]!, value: g.value, gradeId: g.id))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
    } else {
      series = const [];
    }
    return SubjectAnalytics(
      subject: subject,
      grades: filtered,
      averageGrade: Grade.calculateGPA(filtered),
      gradeSeries: series,
    );
  }
}
