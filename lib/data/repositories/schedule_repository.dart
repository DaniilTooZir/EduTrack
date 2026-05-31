import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/utils/app_result.dart';

class ScheduleRepository {
  final ScheduleService _remote;
  final AppDatabase _local;

  ScheduleRepository({required ScheduleService remote, required AppDatabase local}) : _remote = remote, _local = local;

  Future<AppResult<List<Schedule>>> getScheduleForStudent(
    String studentId,
    String? groupId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (groupId == null) return AppResult.failure('ID группы не найден.');
    final result = await _remote.getScheduleForStudent(studentId, groupId, startDate: startDate, endDate: endDate);
    if (result.isSuccess) {
      await _local.saveSchedules(result.data);
      return result;
    }
    final cached = await _local.getSchedulesForGroup(groupId);
    return AppResult.success(cached);
  }

  Future<AppResult<List<Schedule>>> getScheduleForTeacher(
    String teacherId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result = await _remote.getScheduleForTeacher(teacherId, startDate: startDate, endDate: endDate);
    if (result.isSuccess) {
      await _local.saveSchedules(result.data);
      return result;
    }
    final cached = await _local.getSchedulesForTeacher(teacherId);
    return AppResult.success(cached);
  }

  Future<AppResult<List<Schedule>>> getScheduleForInstitution(String institutionId) =>
      _remote.getScheduleForInstitution(institutionId);

  Future<AppResult<Schedule?>> getScheduleById(String id) => _remote.getScheduleById(id);

  Future<AppResult<void>> addScheduleEntry({
    required String institutionId,
    required String subjectId,
    required String groupId,
    required String teacherId,
    required DateTime date,
    required int weekday,
    required String startTime,
    required String endTime,
  }) => _remote.addScheduleEntry(
    institutionId: institutionId,
    subjectId: subjectId,
    groupId: groupId,
    teacherId: teacherId,
    date: date,
    weekday: weekday,
    startTime: startTime,
    endTime: endTime,
  );

  Future<AppResult<void>> deleteScheduleEntry(String id) => _remote.deleteScheduleEntry(id);

  Future<AppResult<String?>> checkConflict({
    required String institutionId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String teacherId,
    required String groupId,
    String? excludeId,
  }) => _remote.checkConflict(
    institutionId: institutionId,
    date: date,
    startTime: startTime,
    endTime: endTime,
    teacherId: teacherId,
    groupId: groupId,
    excludeId: excludeId,
  );

  Future<AppResult<({int copied, int skipped})>> copyScheduleToNextWeek(
    String institutionId,
    DateTime startOfCurrentWeek,
  ) => _remote.copyScheduleToNextWeek(institutionId, startOfCurrentWeek);

  Future<AppResult<void>> updateScheduleEntry({
    required String id,
    required String subjectId,
    required String groupId,
    required String teacherId,
    required DateTime date,
    required int weekday,
    required String startTime,
    required String endTime,
  }) => _remote.updateScheduleEntry(
    id: id,
    subjectId: subjectId,
    groupId: groupId,
    teacherId: teacherId,
    date: date,
    weekday: weekday,
    startTime: startTime,
    endTime: endTime,
  );
}
