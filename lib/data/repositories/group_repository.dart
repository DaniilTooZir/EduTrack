import 'dart:async';

import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/utils/app_result.dart';

class GroupRepository {
  final GroupService _groupService;
  final StudentService _studentService;
  final AppDatabase _local;

  GroupRepository({
    required GroupService groupService,
    required StudentService studentService,
    required AppDatabase local,
  }) : _groupService = groupService,
       _studentService = studentService,
       _local = local;

  // Cache-first: группа куратора
  Future<AppResult<Group?>> getGroupByCurator(String teacherId) async {
    final cached = await _local.getGroupByCuratorId(teacherId);
    if (cached != null) {
      unawaited(
        _groupService.getGroupByCurator(teacherId).then((result) async {
          if (result.isSuccess && result.data != null) {
            await _local.saveGroupDetail(result.data!);
          }
        }),
      );
      return AppResult.success(cached);
    }
    final result = await _groupService.getGroupByCurator(teacherId);
    if (result.isSuccess && result.data != null) {
      await _local.saveGroupDetail(result.data!);
    }
    return result;
  }

  // Cache-first: список студентов группы
  Future<AppResult<List<Student>>> getStudentsByGroupId(String groupId) async {
    final cached = await _local.getStudentsByGroupId(groupId);
    if (cached.isNotEmpty) {
      unawaited(
        _studentService.getStudentsByGroupId(groupId).then((result) async {
          if (result.isSuccess) await _local.saveStudents(result.data);
        }),
      );
      return AppResult.success(cached);
    }
    final result = await _studentService.getStudentsByGroupId(groupId);
    if (result.isSuccess) await _local.saveStudents(result.data);
    return result;
  }

  // Назначение старосты
  Future<AppResult<void>> setHeadman(String groupId, String studentId) async {
    final result = await _studentService.setHeadman(groupId, studentId);
    if (result.isSuccess) {
      final students = await _local.getStudentsByGroupId(groupId);
      final updated = students.map((s) => s.copyWith(isHeadman: s.id == studentId)).toList();
      unawaited(_local.saveStudents(updated));
    }
    return result;
  }
}
