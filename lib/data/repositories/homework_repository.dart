import 'dart:async';

import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/homework_status.dart';
import 'package:edu_track/utils/app_result.dart';

class HomeworkRepository {
  final HomeworkService _remote;
  final AppDatabase _local;

  HomeworkRepository({required HomeworkService remote, required AppDatabase local}) : _remote = remote, _local = local;

  // Cache-first: возвращает локальные ДЗ сразу, обновляет кэш в фоне
  Future<AppResult<List<Homework>>> getHomeworksForStudentGroup(String studentId, String groupId) async {
    final cached = await _local.getHomeworksByGroup(groupId);
    if (cached.isNotEmpty) {
      unawaited(
        _remote.getHomeworksByStudentGroup(studentId).then((result) {
          if (result.isSuccess) _local.saveHomeworks(result.data);
        }),
      );
      return AppResult.success(cached);
    }
    final result = await _remote.getHomeworksByStudentGroup(studentId);
    if (result.isSuccess) await _local.saveHomeworks(result.data);
    return result;
  }

  // Cache-first: возвращает локальные статусы сразу, обновляет кэш в фоне
  Future<AppResult<List<HomeworkStatus>>> getStatusesForStudent(String studentId) async {
    final cached = await _local.getHomeworkStatusesByStudent(studentId);
    if (cached.isNotEmpty) {
      unawaited(
        _remote.getHomeworkStatusesForStudent(studentId).then((result) {
          if (result.isSuccess) _local.saveHomeworkStatuses(result.data);
        }),
      );
      return AppResult.success(cached);
    }
    final result = await _remote.getHomeworkStatusesForStudent(studentId);
    if (result.isSuccess) await _local.saveHomeworkStatuses(result.data);
    return result;
  }

  // Все операции записи напрямую на сервер

  Future<AppResult<void>> addHomework({
    required String institutionId,
    required String subjectId,
    required String groupId,
    required String title,
    String? description,
    DateTime? dueDate,
    String? fileUrl,
    String? fileName,
  }) => _remote.addHomework(
    institutionId: institutionId,
    subjectId: subjectId,
    groupId: groupId,
    title: title,
    description: description,
    dueDate: dueDate,
    fileUrl: fileUrl,
    fileName: fileName,
  );

  Future<AppResult<void>> updateHomework({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? groupId,
    String? fileUrl,
    String? fileName,
    bool deleteFile = false,
  }) => _remote.updateHomework(
    id: id,
    title: title,
    description: description,
    dueDate: dueDate,
    groupId: groupId,
    fileUrl: fileUrl,
    fileName: fileName,
    deleteFile: deleteFile,
  );

  Future<AppResult<void>> deleteHomework(String id) => _remote.deleteHomework(id);

  Future<AppResult<void>> evaluateHomework({
    required String homeworkId,
    required String studentId,
    required bool isCompleted,
    String? teacherComment,
  }) => _remote.evaluateHomework(
    homeworkId: homeworkId,
    studentId: studentId,
    isCompleted: isCompleted,
    teacherComment: teacherComment,
  );

  Future<AppResult<void>> submitHomework({
    required String homeworkId,
    required String studentId,
    String? comment,
    String? fileUrl,
    String? fileName,
  }) => _remote.submitHomework(
    homeworkId: homeworkId,
    studentId: studentId,
    comment: comment,
    fileUrl: fileUrl,
    fileName: fileName,
  );

  Future<AppResult<void>> cancelSubmission({required String homeworkId, required String studentId}) =>
      _remote.cancelSubmission(homeworkId: homeworkId, studentId: studentId);

  Future<AppResult<List<HomeworkStatus>>> getStatusesByHomeworkId(String homeworkId) =>
      _remote.getStatusesByHomeworkId(homeworkId);

  Future<AppResult<List<Homework>>> getHomeworkByTeacherId(String teacherId) =>
      _remote.getHomeworkByTeacherId(teacherId);

  Future<AppResult<List<Homework>>> getHomeworksForStudent(String studentId) =>
      _remote.getHomeworksForStudent(studentId);

  Future<AppResult<List<HomeworkStatus>>> getHomeworkStatusesForStudent(String studentId) =>
      _remote.getHomeworkStatusesForStudent(studentId);

  Future<AppResult<Map<String, dynamic>?>> getGroupByStudentId(String studentId) =>
      _remote.getGroupByStudentId(studentId);

  Future<AppResult<List<Homework>>> getHomeworksByStudentGroup(String studentId) =>
      _remote.getHomeworksByStudentGroup(studentId);
}
