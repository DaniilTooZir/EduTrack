import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/utils/app_result.dart';

class InstitutionRequestStatusService {
  static Future<AppResult<Map<String, dynamic>?>> getRequestDetailsByEmail(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final request =
          await SupabaseConnection.client
              .from('institution_requests')
              .select('status')
              .eq('email', normalizedEmail)
              .maybeSingle();
      if (request == null) {
        return AppResult.success(null);
      }
      final status = request['status'] as String;
      if (status != 'approved') {
        return AppResult.success({'status': status});
      }
      final head =
          await SupabaseConnection.client
              .from('education_heads')
              .select('login, password')
              .eq('email', normalizedEmail)
              .maybeSingle();
      if (head == null) {
        return AppResult.success({'status': status});
      }
      return AppResult.success({'status': status, 'login': head['login'], 'password': head['password']});
    } catch (e) {
      return AppResult.failure('Не удалось проверить статус заявки. Проверьте соединение.');
    }
  }
}
