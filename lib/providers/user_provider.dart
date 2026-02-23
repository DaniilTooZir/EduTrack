import 'package:flutter/foundation.dart';
import 'package:edu_track/data/services/session_service.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _role;
  String? _institutionId;
  String? _groupId;

  String? get userId => _userId;
  String? get role => _role;
  String? get institutionId => _institutionId;
  String? get groupId => _groupId;

  // Сохраняет данные пользователя и уведомляет слушателей
  void setUser(String userId, String role, String institutionId, String? groupId) {
    _userId = userId;
    _role = role;
    _institutionId = institutionId;
    _groupId = groupId;
    SessionService.saveSession(userId, role, institutionId, groupId);
    notifyListeners();
  }

  // Очищает данные пользователя и уведомляет слушателей
  void clearUser() {
    _userId = null;
    _role = null;
    _groupId = null;
    SessionService.clearSession();
    notifyListeners();
  }

  // Загружает данные пользователя из сессии
  void loadSession(String? userId, String? role, String? institutionId, String? groupId) {
    if (userId != null && role != null && institutionId != null) {
      _userId = userId;
      _role = role;
      _institutionId = institutionId;
      _groupId = groupId;
      notifyListeners();
    }
  }
}
