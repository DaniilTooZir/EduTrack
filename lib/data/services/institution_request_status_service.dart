import 'package:edu_track/data/database/connection_to_database.dart';

class InstitutionRequestStatusService {
  static Future<Map<String, dynamic>?> getRequestDetailsByEmail(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final request =
          await SupabaseConnection.client
              .from('institution_requests')
              .select('status')
              .eq('email', normalizedEmail)
              .maybeSingle();

      if (request == null) {
        print('[StatusService] Заявка не найдена для email: $normalizedEmail');
        return null;
      }

      final status = request['status'] as String;
      print('[StatusService] Статус заявки: $status');

      if (status != 'approved') {
        return {'status': status};
      }

      final head =
          await SupabaseConnection.client
              .from('education_heads')
              .select('login, password')
              .eq('email', normalizedEmail)
              .maybeSingle();

      if (head == null) {
        print('[StatusService] Не найден руководитель по email: $normalizedEmail');
        return {'status': status};
      }

      return {'status': status, 'login': head['login'], 'password': head['password']};
    } catch (e, stackTrace) {
      print('[StatusService] Ошибка при получении данных по email: $email');
      print('[StatusService] $e');
      print('[StatusService] $stackTrace');
      throw Exception('Не удалось проверить статус. Проверьте соединение.');
    }
  }
}
