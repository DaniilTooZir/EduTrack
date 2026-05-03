import 'package:edu_track/models/institution.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InstitutionService {
  final _client = Supabase.instance.client;

  Future<AppResult<Institution?>> getInstitutionById(String id) async {
    try {
      final data = await _client.from('institutions').select().eq('id', id).maybeSingle();
      if (data == null) return AppResult.success(null);
      return AppResult.success(Institution.fromMap(data));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении данных учреждения: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить данные учреждения.');
    }
  }
}
