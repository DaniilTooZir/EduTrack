import 'dart:async';

import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/debt_service.dart';
import 'package:edu_track/models/student_debt_info.dart';
import 'package:edu_track/utils/app_result.dart';

class DebtRepository {
  final DebtService _remote;
  final AppDatabase _local;

  DebtRepository({required DebtService remote, required AppDatabase local}) : _remote = remote, _local = local;

  // Cache-first: группы преподавателя из кэша расписания
  Future<AppResult<List<({String id, String name})>>> getTeacherGroups(String teacherId) async {
    final cached = await _local.getGroupsByTeacherId(teacherId);
    if (cached.isNotEmpty) {
      return AppResult.success(cached.map((g) => (id: g.id!, name: g.name)).toList());
    }
    return _remote.getTeacherGroups(teacherId);
  }

  // Cache-first: задолженности вычисляются из локальных данных
  Future<AppResult<List<StudentDebtInfo>>> getGroupDebts({
    required String groupId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final cachedStudents = await _local.getStudentsByGroupId(groupId);
    if (cachedStudents.isNotEmpty) {
      final debts = await _computeDebtsLocally(
        students: cachedStudents,
        groupId: groupId,
        startDate: startDate,
        endDate: endDate,
      );
      unawaited(_remote.getGroupDebts(groupId: groupId, startDate: startDate, endDate: endDate).then((_) {}));
      return AppResult.success(debts);
    }
    return _remote.getGroupDebts(groupId: groupId, startDate: startDate, endDate: endDate);
  }

  Future<AppResult<double>> getStudentOverallAverage(String studentId) => _remote.getStudentOverallAverage(studentId);

  Future<List<StudentDebtInfo>> _computeDebtsLocally({
    required List<dynamic> students,
    required String groupId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final homeworks = await _local.getHomeworksByGroup(groupId);
    final studentIds = students.map((s) => s.id as String).toList();

    final allGrades = await _local.getGradesByStudentIds(studentIds);

    final hwIds = homeworks.map((h) => h.id).toList();
    final allStatuses = await _local.getHomeworkStatusesByHomeworkIds(hwIds);

    Map<String, DateTime> lessonDateMap = {};
    if ((startDate != null || endDate != null) && allGrades.isNotEmpty) {
      final lessonIds = allGrades.map((g) => g.lessonId).toSet().toList();
      lessonDateMap = await _local.getLessonDateMap(lessonIds);
    }

    return students.map((student) {
      var studentGrades = allGrades.where((g) => g.studentId == student.id).toList();
      if ((startDate != null || endDate != null) && lessonDateMap.isNotEmpty) {
        studentGrades =
            studentGrades.where((g) {
              final date = lessonDateMap[g.lessonId];
              if (date == null) return true;
              if (startDate != null && date.isBefore(startDate)) return false;
              if (endDate != null && date.isAfter(endDate)) return false;
              return true;
            }).toList();
      }

      final avg =
          studentGrades.isEmpty ? 0.0 : studentGrades.fold<int>(0, (acc, g) => acc + g.value) / studentGrades.length;

      final studentStatuses = allStatuses.where((s) => s.studentId == student.id).toList();
      final statusMap = {for (final s in studentStatuses) s.homeworkId: s};

      int pendingCount = 0;
      final pendingTitles = <String>[];
      for (final hw in homeworks) {
        final status = statusMap[hw.id];
        if (status == null || !status.isCompleted) {
          pendingCount++;
          pendingTitles.add(hw.title);
        }
      }

      return StudentDebtInfo(
        student: student,
        averageGrade: avg,
        pendingHomeworkCount: pendingCount,
        pendingHomeworkTitles: pendingTitles,
      );
    }).toList();
  }
}
