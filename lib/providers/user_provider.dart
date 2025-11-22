import 'package:flutter/foundation.dart';
import 'package:edu_track/data/services/session_service.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _role;
  String? _institutionId;

  String? get userId => _userId;
  String? get role => _role;
  String? get institutionId => _institutionId;

  // Сохраняет данные пользователя и уведомляет слушателей
  void setUser(String userId, String role, String institutionId) {
    _userId = userId;
    _role = role;
    _institutionId = institutionId;
    SessionService.saveSession(userId, role, institutionId);
    notifyListeners();
  }

  // Очищает данные пользователя и уведомляет слушателей
  void clearUser() {
    _userId = null;
    _role = null;
    SessionService.clearSession();
    notifyListeners();
  }

  // Загружает данные пользователя из сессии
  void loadSession(String? userId, String? role, String? institutionId) {
    if (userId != null && role != null && institutionId != null) {
      _userId = userId;
      _role = role;
      _institutionId = institutionId;
      notifyListeners();
    }
  }
}
