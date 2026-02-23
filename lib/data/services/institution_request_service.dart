import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InstitutionRequestService {
  final SupabaseClient _client;
  InstitutionRequestService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<void> submitInstitutionRequest({
    required String name,
    required String address,
    required String headName,
    required String headSurname,
    required String email,
    String? phone,
    String? comment,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final existingAdmin = await _client.from('education_heads').select('id').eq('email', cleanEmail).maybeSingle();
      if (existingAdmin != null) {
        throw Exception('Пользователь с таким email уже зарегистрирован как руководитель.');
      }
      final existingRequest =
          await _client
              .from('institution_requests')
              .select('status')
              .eq('email', cleanEmail)
              .neq('status', 'rejected')
              .maybeSingle();
      if (existingRequest != null) {
        final status = existingRequest['status'];
        if (status == 'approved') {
          throw Exception('Заявка с таким email уже одобрена. Проверьте статус.');
        } else {
          throw Exception('Заявка с таким email уже находится на рассмотрении.');
        }
      }
      final dataToInsert = {
        'name': name.trim(),
        'address': address.trim(),
        'head_name': headName.trim(),
        'head_surname': headSurname.trim(),
        'email': email.trim(),
        'phone': phone?.trim(),
        'comment': comment?.trim(),
        'status': 'pending',
      };
      final response = await _client.from('institution_requests').insert(dataToInsert).select().single();

      print('[InstitutionRequestService] Заявка успешно отправлена: ${response['id']}');
    } on PostgrestException catch (e) {
      print('[InstitutionRequestService] Ошибка БД: ${e.message} (Code: ${e.code})');
      throw Exception('Ошибка базы данных: ${e.message}');
    } catch (e, stackTrace) {
      print('[InstitutionRequestService] Неизвестная ошибка: $e');
      print('[InstitutionRequestService] StackTrace: $stackTrace');
      rethrow;
    }
  }
}
