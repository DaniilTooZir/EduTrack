import 'package:supabase_flutter/supabase_flutter.dart';

class InstitutionRequestStatusService {
  static Future<Map<String, dynamic>?> getRequestDetailsByEmail(String email) async {
    try {
      final request = await Supabase.instance.client
          .from('institution_requests')
          .select('status')
          .eq('email', email)
          .maybeSingle();

      if (request == null) {
        print('[StatusService] Заявка не найдена для email: $email');
        return null;
      }

      final status = request['status'] as String;
      print('[StatusService] Статус заявки: $status');

      if (status != 'approved') {
        return {'status': status};
      }

      final head = await Supabase.instance.client
          .from('education_heads')
          .select('login, password')
          .eq('email', email)
          .maybeSingle();

      if (head == null) {
        print('[StatusService] Не найден руководитель по email: $email');
        return {'status': status};
      }

      return {
        'status': status,
        'login': head['login'],
        'password': head['password'],
      };
    } catch (e, stackTrace) {
      print('[StatusService] Ошибка при получении данных по email: $email');
      print('[StatusService] $e');
      print('[StatusService] $stackTrace');
      return null;
    }
  }
}