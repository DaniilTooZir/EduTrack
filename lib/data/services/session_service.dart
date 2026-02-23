import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  // Сохраняет данные сессии пользователя в SharedPreferences
  static Future<void> saveSession(String userId, String role, String institutionId, String? groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('role', role);
    await prefs.setString('institutionId', institutionId);
    if (groupId != null) {
      await prefs.setString('groupId', groupId);
    }
  }

  // Получает ID пользователя из сессии
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Получает роль пользователя из сессии
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // Получает ID учреждения пользователя из сессии
  static Future<String?> getInstitutionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('institutionId');
  }

  static Future<String?> getGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('groupId');
  }

  // Очищает данные сессии
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('role');
    await prefs.remove('institutionId');
  }
}
