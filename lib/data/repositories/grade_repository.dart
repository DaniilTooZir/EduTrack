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
    final result = await _remote.getGradesByStudent(studentId);
    if (result.isSuccess) {
      await _local.saveGrades(result.data);
      return result;
    }
    final cached = await _local.getGradesByStudent(studentId);
    if (cached.isNotEmpty) return AppResult.success(cached);
    return result;
  }

  Future<AppResult<List<Grade>>> getGradesByLesson(String lessonId) async {
    final result = await _remote.getGradesByLesson(lessonId);
    if (result.isSuccess) {
      await _local.saveGrades(result.data);
      return result;
    }
    final cached = await _local.getGradesByLesson(lessonId);
    if (cached.isNotEmpty) return AppResult.success(cached);
    return result;
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
