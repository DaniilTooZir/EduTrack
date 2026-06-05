import 'dart:async';

import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/grade_service.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/subject_analytics.dart';
import 'package:edu_track/utils/app_result.dart';

class GradeRepository {
  final GradeService _remote;
  final AppDatabase _local;

  GradeRepository({required GradeService remote, required AppDatabase local}) : _remote = remote, _local = local;

  Future<AppResult<List<Grade>>> getGradesByStudent(String studentId) async {
    final cached = await _local.getGradesByStudent(studentId);
    if (cached.isNotEmpty) {
      unawaited(
        _remote.getGradesByStudent(studentId).then((result) {
          if (result.isSuccess) _local.saveGrades(result.data);
        }),
      );
      return AppResult.success(cached);
    }
    final result = await _remote.getGradesByStudent(studentId);
    if (result.isSuccess) await _local.saveGrades(result.data);
    return result;
  }

  Future<AppResult<List<Grade>>> getGradesByLesson(String lessonId) async {
    final cached = await _local.getGradesByLesson(lessonId);
    if (cached.isNotEmpty) {
      unawaited(
        _remote.getGradesByLesson(lessonId).then((result) {
          if (result.isSuccess) _local.saveGrades(result.data);
        }),
      );
      return AppResult.success(cached);
    }
    final result = await _remote.getGradesByLesson(lessonId);
    if (result.isSuccess) await _local.saveGrades(result.data);
    return result;
  }

  // Возвращает средний балл студента, используя кэшированные оценки
  Future<double> getStudentAverage(String studentId) async {
    final result = await getGradesByStudent(studentId);
    if (result.isFailure || result.data.isEmpty) return 0.0;
    return result.data.fold<int>(0, (acc, g) => acc + g.value) / result.data.length;
  }

  Future<AppResult<String>> addOrUpdateGrade(Grade grade) => _remote.addOrUpdateGrade(grade);

  Future<AppResult<Map<String, dynamic>>> getJournalData({
    required String groupId,
    required String subjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) => _remote.getJournalData(groupId: groupId, subjectId: subjectId, startDate: startDate, endDate: endDate);

  Future<AppResult<List<SubjectAnalytics>>> getStudentAnalytics(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) => _remote.getStudentAnalytics(studentId, startDate: startDate, endDate: endDate);

  Future<AppResult<void>> clearJournalCell({required String studentId, required String lessonId}) =>
      _remote.clearJournalCell(studentId: studentId, lessonId: lessonId);
}
