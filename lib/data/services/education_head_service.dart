import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/education_head.dart';

class EducationHeadService {
  final _client = Supabase.instance.client;

  Future<EducationHead?> getHeadById(String id) async {
    try {
      final data = await _client.from('education_heads').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return EducationHead.fromMap(data);
    } catch (e) {
      print('Error loading head: $e');
      return null;
    }
  }

  Future<void> updateHeadData(String id, Map<String, dynamic> updatedFields) async {
    try {
      await _client.from('education_heads').update(updatedFields).eq('id', id);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Логин или Email уже занят');
      }
      throw Exception('Ошибка базы данных: ${e.message}');
    } catch (e) {
      throw Exception('Неизвестная ошибка при обновлении');
    }
  }
}
