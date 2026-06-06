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

  Future<AppResult<String>> addOrUpdateGrade(Grade grade) async {
    final result = await _remote.addOrUpdateGrade(grade);
    if (result.isSuccess) {
      unawaited(_local.saveGrade(grade.copyWith(id: result.data)));
    }
    return result;
  }

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
  }) async {
    final cached = await _computeAnalyticsFromCache(studentId, startDate: startDate, endDate: endDate);
    if (cached != null) {
      unawaited(_fetchAndCacheAnalytics(studentId));
      return AppResult.success(cached);
    }
    return _fetchAndCacheAnalytics(studentId, startDate: startDate, endDate: endDate);
  }

  Future<List<SubjectAnalytics>?> _computeAnalyticsFromCache(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final grades = await _local.getGradesByStudent(studentId);
    if (grades.isEmpty) return null;

    final lessonIds = grades.map((g) => g.lessonId).toSet().toList();
    final lessonScheduleMap = await _local.getLessonScheduleMap(lessonIds);
    if (lessonScheduleMap.isEmpty) return null;

    final scheduleIds = lessonScheduleMap.values.toSet().toList();
    final scheduleData = await _local.getScheduleSubjectDateMap(scheduleIds);
    if (scheduleData.isEmpty) return null;

    final subjectIds = scheduleData.values.map((v) => v.subjectId).toSet().toList();
    final subjectsById = await _local.getSubjectsByIds(subjectIds);
    if (subjectsById.isEmpty) return null;

    final lessonSubjectMap = <String, String>{};
    final lessonDateMap = <String, DateTime>{};
    for (final e in lessonScheduleMap.entries) {
      final sd = scheduleData[e.value];
      if (sd != null) {
        lessonSubjectMap[e.key] = sd.subjectId;
        if (sd.date != null) lessonDateMap[e.key] = sd.date!;
      }
    }

    final filteredGrades = _applyDateFilter(grades, lessonDateMap, startDate, endDate);
    return subjectsById.values
        .map((s) => SubjectAnalytics.fromGrades(s, filteredGrades, lessonSubjectMap, lessonDateMap: lessonDateMap))
        .where((a) => a.grades.isNotEmpty)
        .toList()
      ..sort((a, b) => a.subject.name.compareTo(b.subject.name));
  }

  Future<AppResult<List<SubjectAnalytics>>> _fetchAndCacheAnalytics(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result = await _remote.getStudentAnalytics(studentId, startDate: startDate, endDate: endDate);
    if (result.isSuccess && result.data.isNotEmpty) {
      final allGrades = result.data.expand((a) => a.grades).toList();
      unawaited(_local.saveGrades(allGrades));
      final lessonIds = allGrades.map((g) => g.lessonId).toSet().toList();
      if (lessonIds.isNotEmpty) {
        unawaited(
          _remote.getLessonScheduleMapping(lessonIds).then((r) {
            if (r.isSuccess) _local.saveLessons(r.data);
          }),
        );
      }
    }
    return result;
  }

  List<Grade> _applyDateFilter(
    List<Grade> grades,
    Map<String, DateTime> lessonDateMap,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return grades;
    return grades.where((g) {
      final date = lessonDateMap[g.lessonId];
      if (date == null) return true;
      if (startDate != null && date.isBefore(startDate)) return false;
      if (endDate != null && date.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  Future<AppResult<void>> clearJournalCell({required String studentId, required String lessonId}) async {
    final result = await _remote.clearJournalCell(studentId: studentId, lessonId: lessonId);
    if (result.isSuccess) {
      unawaited(_local.deleteGradeByLessonAndStudent(lessonId, studentId));
    }
    return result;
  }
}
