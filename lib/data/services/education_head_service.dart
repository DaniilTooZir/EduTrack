import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/education_head.dart';

class EducationHeadService {
  final _client = Supabase.instance.client;

  Future<AppResult<EducationHead?>> getHeadById(String id) async {
    try {
      final data = await _client.from('education_heads').select().eq('id', id).maybeSingle();
      if (data == null) return AppResult.success(null);
      return AppResult.success(EducationHead.fromMap(data));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке данных руководителя: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить данные руководителя.');
    }
  }

  Future<AppResult<void>> updateHeadData(String id, Map<String, dynamic> updatedFields) async {
    try {
      await _client.from('education_heads').update(updatedFields).eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Логин или Email уже занят.');
      }
      return AppResult.failure('Ошибка базы данных: ${e.message}');
    } catch (e) {
      return AppResult.failure('Неизвестная ошибка при обновлении данных.');
    }
  }
}
