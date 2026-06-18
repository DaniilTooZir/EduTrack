import 'dart:async';

import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/repositories/chat_repository.dart';
import 'package:edu_track/data/repositories/grade_repository.dart';
import 'package:edu_track/data/repositories/group_repository.dart';
import 'package:edu_track/data/repositories/homework_repository.dart';
import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/data/repositories/subject_repository.dart';
import 'package:flutter/foundation.dart';

class PrefetchService {
  final ScheduleRepository _scheduleRepo;
  final HomeworkRepository _hwRepo;
  final SubjectRepository _subjectRepo;
  final GroupRepository _groupRepo;
  final ChatRepository _chatRepo;
  final GradeRepository _gradeRepo;
  final AppDatabase _db;

  PrefetchService({
    required ScheduleRepository scheduleRepo,
    required HomeworkRepository hwRepo,
    required SubjectRepository subjectRepo,
    required GroupRepository groupRepo,
    required ChatRepository chatRepo,
    required GradeRepository gradeRepo,
    required AppDatabase db,
  }) : _scheduleRepo = scheduleRepo,
       _hwRepo = hwRepo,
       _subjectRepo = subjectRepo,
       _groupRepo = groupRepo,
       _chatRepo = chatRepo,
       _gradeRepo = gradeRepo,
       _db = db;

  void prefetchForUser(String userId, String role, String? groupId) {
    if (role == 'teacher') {
      unawaited(_prefetchTeacher(userId));
    } else if (role == 'student' && groupId != null) {
      unawaited(_prefetchStudent(userId, groupId));
    }
  }

  Future<void> _prefetchTeacher(String userId) async {
    try {
      await Future.wait([
        _scheduleRepo.getScheduleForTeacher(userId),
        _hwRepo.getHomeworkByTeacherId(userId),
        _subjectRepo.getSubjectsByTeacherId(userId),
        _chatRepo.getEnrichedUserChats(userId),
      ]);

      final groups = await _db.getGroupsByTeacherId(userId);
      if (groups.isNotEmpty) {
        final groupIds = groups.map((g) => g.id).whereType<String>().toList();
        await Future.wait(groupIds.map(_groupRepo.getStudentsByGroupId));
      }

      final homeworks = await _db.getHomeworksByTeacherGroups(userId);
      if (homeworks.isNotEmpty) {
        await Future.wait(homeworks.map((hw) => _hwRepo.getStatusesByHomeworkId(hw.id)));
      }

      // Prefetch журнала для каждой пары группа+предмет из расписания
      final schedules = await _db.getSchedulesForTeacher(userId);
      final groupSubjectPairs = <({String groupId, String subjectId})>{};
      for (final s in schedules) {
        groupSubjectPairs.add((groupId: s.groupId, subjectId: s.subjectId));
      }
      if (groupSubjectPairs.isNotEmpty) {
        await Future.wait(
          groupSubjectPairs.map((p) => _gradeRepo.getJournalData(groupId: p.groupId, subjectId: p.subjectId)),
        );
      }
    } catch (e) {
      debugPrint('PrefetchService teacher: $e');
    }
  }

  Future<void> _prefetchStudent(String userId, String groupId) async {
    try {
      await Future.wait([
        _scheduleRepo.getScheduleForStudent(userId, groupId),
        _hwRepo.getHomeworksForStudentGroup(userId, groupId),
        _chatRepo.getEnrichedUserChats(userId),
      ]);
    } catch (e) {
      debugPrint('PrefetchService student: $e');
    }
  }
}
