import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/schedule_operator.dart';
import 'package:edu_track/utils/app_result.dart';

class ScheduleOperatorService {
  static final client = SupabaseConnection.client;

  static Future<AppResult<ScheduleOperator?>> getOperatorByLogin(String login) async {
    try {
      final data = await client.from('schedule_operators').select().eq('login', login).maybeSingle();
      if (data == null) return AppResult.success(null);
      return AppResult.success(ScheduleOperator.fromMap(data));
    } catch (e) {
      return AppResult.failure('Не удалось загрузить данные оператора расписания.');
    }
  }

  static Future<AppResult<ScheduleOperator?>> getById(String id) async {
    try {
      final data = await client.from('schedule_operators').select().eq('id', id).maybeSingle();
      if (data == null) return AppResult.success(null);
      return AppResult.success(ScheduleOperator.fromMap(data));
    } catch (e) {
      return AppResult.failure('Не удалось загрузить данные оператора расписания.');
    }
  }
}
