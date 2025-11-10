import 'package:edu_track/data/database/connection_to_database.dart';

class AuthResult {
  final String role;
  final String userId;
  final String institutionId;

  AuthResult({required this.role, required this.userId, required this.institutionId});
}

class AuthService {
  static Future<AuthResult?> login(String login, String password) async {
    final client = SupabaseConnection.client;

    try {
      final admin =
          await client.from('education_heads').select('id, password, institution_id').eq('login', login).maybeSingle();

      if (admin != null && admin['password'] == password) {
        return AuthResult(role: 'admin', userId: admin['id'], institutionId: admin['institution_id']);
      }
    } catch (e) {
      print('Ошибка при попытке входа админа: $e');
    }

    try {
      final teacher =
          await client.from('teachers').select('id, password, institution_id').eq('login', login).maybeSingle();

      if (teacher != null && teacher['password'] == password) {
        return AuthResult(role: 'teacher', userId: teacher['id'], institutionId: teacher['institution_id']);
      }
    } catch (e) {
      print('Ошибка при попытке входа преподавателя: $e');
    }

    try {
      final student =
          await client.from('students').select('id, password, institution_id').eq('login', login).maybeSingle();

      if (student != null && student['password'] == password) {
        return AuthResult(role: 'student', userId: student['id'], institutionId: student['institution_id']);
      }
    } catch (e) {
      print('Ошибка при попытке входа ученика: $e');
    }

    try {
      final operator =
          await client
              .from('schedule_operators')
              .select('id, password, institution_id')
              .eq('login', login)
              .maybeSingle();

      if (operator != null && operator['password'] == password) {
        return AuthResult(role: 'schedule_operator', userId: operator['id'], institutionId: operator['institution_id']);
      }
    } catch (e) {
      print('Ошибка при попытке входа оператора расписания: $e');
    }

    return null;
  }
}
