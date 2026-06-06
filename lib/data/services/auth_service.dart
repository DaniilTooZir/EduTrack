import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/utils/app_result.dart';

class AuthResult {
  final String role;
  final String userId;
  final String institutionId;
  final String? groupId;
  final String? name;
  final String? surname;
  final String? email;
  final String? avatarUrl;
  final String? institutionName;
  final String? groupName;
  AuthResult({
    required this.role,
    required this.userId,
    required this.institutionId,
    this.groupId,
    this.name,
    this.surname,
    this.email,
    this.avatarUrl,
    this.institutionName,
    this.groupName,
  });
}

class AuthService {
  static const _studentSelect = '*, groups(name, institution_id, institutions(name))';
  static const _defaultSelect = '*, institutions(name)';

  static Future<AppResult<AuthResult?>> login(String login, String password) async {
    try {
      var result = await _checkUser(table: 'education_heads', role: 'admin', login: login, password: password);
      if (result != null) return AppResult.success(result);
      result = await _checkUser(table: 'teachers', role: 'teacher', login: login, password: password);
      if (result != null) return AppResult.success(result);
      result = await _checkUser(table: 'students', role: 'student', login: login, password: password);
      if (result != null) return AppResult.success(result);
      result = await _checkUser(
        table: 'schedule_operators',
        role: 'schedule_operator',
        login: login,
        password: password,
      );
      if (result != null) return AppResult.success(result);
      return AppResult.success(null);
    } catch (e) {
      return AppResult.failure('Ошибка при выполнении авторизации. Проверьте соединение.');
    }
  }

  static Future<AuthResult?> fetchById(String userId, String role) async {
    final table = switch (role) {
      'admin' => 'education_heads',
      'teacher' => 'teachers',
      'student' => 'students',
      'schedule_operator' => 'schedule_operators',
      _ => '',
    };
    if (table.isEmpty) return null;
    try {
      final selectStr = role == 'student' ? _studentSelect : _defaultSelect;
      final data = await SupabaseConnection.client.from(table).select(selectStr).eq('id', userId).maybeSingle();
      return data == null ? null : _parseResult(data, role);
    } catch (_) {
      return null;
    }
  }

  static Future<AuthResult?> _checkUser({
    required String table,
    required String role,
    required String login,
    required String password,
  }) async {
    final selectStr = role == 'student' ? _studentSelect : _defaultSelect;
    final data = await SupabaseConnection.client.from(table).select(selectStr).eq('login', login).maybeSingle();
    if (data == null || data['password'] != password) return null;
    return _parseResult(data, role);
  }

  static AuthResult _parseResult(Map<String, dynamic> data, String role) {
    final String instId;
    final String? instName;
    final String? gName;

    if (role == 'student') {
      final groupData = data['groups'] as Map<String, dynamic>?;
      instId = groupData?['institution_id']?.toString() ?? '';
      instName = groupData?['institutions']?['name']?.toString();
      gName = groupData?['name']?.toString();
    } else {
      instId = data['institution_id'].toString();
      instName = data['institutions']?['name'];
      gName = null;
    }

    return AuthResult(
      role: role,
      userId: data['id'].toString(),
      institutionId: instId,
      groupId: data['group_id']?.toString(),
      name: data['name']?.toString(),
      surname: data['surname']?.toString(),
      email: data['email'],
      avatarUrl: data['avatar_url'],
      institutionName: instName,
      groupName: gName,
    );
  }
}
