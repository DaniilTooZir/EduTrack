import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InstitutionRequestService {
  final SupabaseClient _client;
  InstitutionRequestService({SupabaseClient? client})
    : _client = client ?? SupabaseConnection.client;

  Future<void> submitInstitutionRequest({
    required String name,
    required String address,
    required String headName,
    required String headSurname,
    required String email,
    String? phone,
    String? comment,
  }) async {
    final response =
        await _client
            .from('institution_requests')
            .insert({
              'name': name,
              'address': address,
              'head_name': headName,
              'head_surname': headSurname,
              'email': email,
              'phone': phone,
              'comment': comment,
              'status': 'pending',
            })
            .select()
            .single();
    if (response == null) {
      throw Exception('Ошибка при отправке заявки: пустой ответ от сервера');
    }
  }
}
