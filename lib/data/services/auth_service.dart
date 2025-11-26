import 'package:edu_track/data/database/connection_to_database.dart';

class AuthResult {
  final String role;
  final String userId;
  final String institutionId;

  AuthResult({required this.role, required this.userId, required this.institutionId});
}

class AuthService {
  static Future<AuthResult?> login(String login, String password) async {
    var result = await _checkUser(table: 'education_heads', role: 'admin', login: login, password: password);
    if (result != null) return result;

    result = await _checkUser(table: 'teachers', role: 'teacher', login: login, password: password);
    if (result != null) return result;

    result = await _checkUser(table: 'students', role: 'student', login: login, password: password);
    if (result != null) return result;

    result = await _checkUser(table: 'schedule_operators', role: 'schedule_operator', login: login, password: password);
    if (result != null) return result;
    return null;
  }

  static Future<AuthResult?> _checkUser({
    required String table,
    required String role,
    required String login,
    required String password,
  }) async {
    final client = SupabaseConnection.client;
    try {
      final data = await client.from(table).select('id, password, institution_id').eq('login', login).maybeSingle();
      if (data != null && data['password'] == password) {
        return AuthResult(role: role, userId: data['id'], institutionId: data['institution_id']);
      }
    } catch (e) {
      print('Ошибка при проверке роли $role: $e');
    }
    return null;
  }
}
