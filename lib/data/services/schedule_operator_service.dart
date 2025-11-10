import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/schedule_operator.dart';

class ScheduleOperatorService {
  static final client = SupabaseConnection.client;

  static Future<ScheduleOperator?> getOperatorByLogin(String login) async {
    try {
      final data = await client.from('schedule_operators').select().eq('login', login).maybeSingle();
      if (data != null) {
        return ScheduleOperator.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Ошибка при получении оператора расписания: $e');
      return null;
    }
  }

  static Future<ScheduleOperator?> getById(String id) async {
    try {
      final data = await client.from('schedule_operators').select().eq('id', id).maybeSingle();
      if (data != null) {
        return ScheduleOperator.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Ошибка при получении оператора расписания: $e');
      return null;
    }
  }
}
