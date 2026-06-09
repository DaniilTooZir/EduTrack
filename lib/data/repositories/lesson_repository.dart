import 'dart:async';

import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/lesson_service.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/utils/app_result.dart';

class LessonRepository {
  final LessonService _remote;
  final AppDatabase _local;

  LessonRepository({required LessonService remote, required AppDatabase local}) : _remote = remote, _local = local;

  Future<AppResult<List<Lesson>>> getLessonsByScheduleIds(List<String> scheduleIds) async {
    if (scheduleIds.isEmpty) return AppResult.success([]);
    final cached = await _local.getLessonsCachedByScheduleIds(scheduleIds);
    if (cached.isNotEmpty) {
      unawaited(
        _remote.getLessonsByScheduleIds(scheduleIds).then((result) {
          if (result.isSuccess) _local.saveLessonsData(result.data);
        }),
      );
      return AppResult.success(cached);
    }
    final result = await _remote.getLessonsByScheduleIds(scheduleIds);
    if (result.isSuccess) await _local.saveLessonsData(result.data);
    return result;
  }

  Future<AppResult<String>> addLesson(Lesson lesson) async {
    final result = await _remote.addLesson(lesson);
    if (result.isSuccess) {
      await _local.deleteLessonsForSchedules([lesson.scheduleId]);
    }
    return result;
  }

  Future<AppResult<Lesson?>> getLessonById(String id) => _remote.getLessonById(id);
}
