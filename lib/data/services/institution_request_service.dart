import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InstitutionRequestService {
  final SupabaseClient _client;
  InstitutionRequestService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<void>> submitInstitutionRequest({
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
        return AppResult.failure('Пользователь с таким email уже зарегистрирован как руководитель.');
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
          return AppResult.failure('Заявка с таким email уже одобрена. Проверьте статус.');
        } else {
          return AppResult.failure('Заявка с таким email уже находится на рассмотрении.');
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
      await _client.from('institution_requests').insert(dataToInsert).select().single();
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка базы данных при отправке заявки: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось отправить заявку. Проверьте соединение и попробуйте снова.');
    }
  }
}
