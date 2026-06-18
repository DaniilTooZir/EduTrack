import 'dart:async';

import 'package:edu_track/data/repositories/homework_repository.dart';
import 'package:edu_track/data/repositories/user_repository.dart';
import 'package:edu_track/data/services/academic_period_service.dart';
import 'package:edu_track/data/services/auth_service.dart';
import 'package:edu_track/data/services/notification_service.dart';
import 'package:edu_track/data/services/prefetch_service.dart';
import 'package:edu_track/data/services/realtime_listener.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/models/academic_period.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  final HomeworkRepository _homeworkRepository;
  final PrefetchService? _prefetchService;

  UserProvider({
    required UserRepository userRepository,
    required HomeworkRepository homeworkRepository,
    PrefetchService? prefetchService,
  }) : _userRepository = userRepository,
       _homeworkRepository = homeworkRepository,
       _prefetchService = prefetchService;

  String? _userId;
  String? _role;
  String? _institutionId;
  String? _groupId;

  String? _userName;
  String? _userSurname;
  String? _userEmail;
  String? _avatarUrl;
  String? _institutionName;
  String? _groupName;

  List<AcademicPeriod> _periods = [];
  AcademicPeriod? _selectedPeriod;

  bool _isInitialized = false;
  final _realtimeListener = RealtimeListener();

  String? get userId => _userId;
  String? get role => _role;
  String? get institutionId => _institutionId;
  String? get groupId => _groupId;
  String? get userName => _userName;
  String? get userSurname => _userSurname;
  String? get userEmail => _userEmail;
  String? get avatarUrl => _avatarUrl;
  String? get institutionName => _institutionName;
  String? get groupName => _groupName;
  List<AcademicPeriod> get periods => _periods;
  AcademicPeriod? get selectedPeriod => _selectedPeriod;
  bool get isInitialized => _isInitialized;

  Future<void> setUser(AuthResult auth) async {
    _userId = auth.userId;
    _role = auth.role;
    _institutionId = auth.institutionId;
    _groupId = auth.groupId;
    _userName = auth.name;
    _userSurname = auth.surname;
    _userEmail = auth.email;
    _avatarUrl = auth.avatarUrl;
    _institutionName = auth.institutionName;
    _groupName = auth.groupName;
    await SessionService.saveSession(auth.userId, auth.role, auth.institutionId, auth.groupId);
    await _userRepository.saveProfile(auth);
    _setupRealtime();
    notifyListeners();
    unawaited(loadPeriods());
    unawaited(_scheduleHomeworkReminders());
    _prefetchService?.prefetchForUser(auth.userId, auth.role, auth.groupId);
  }

  Future<void> loadSession() async {
    try {
      _userId = await SessionService.getUserId();
      _role = await SessionService.getRole();
      _institutionId = await SessionService.getInstitutionId();
      _groupId = await SessionService.getGroupId();
      if (_userId != null && _role != null) {
        final onlineSuccess = await _fetchFullProfile();
        if (!onlineSuccess) {
          await _loadCachedProfile();
        }
        _setupRealtime();
        _prefetchService?.prefetchForUser(_userId!, _role!, _groupId);
      }
    } catch (e) {
      debugPrint('Ошибка инициализации: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
      unawaited(loadPeriods());
      unawaited(_scheduleHomeworkReminders());
    }
  }

  Future<bool> _fetchFullProfile() async {
    if (_userId == null || _role == null) return false;
    try {
      final auth = await AuthService.fetchById(_userId!, _role!);
      if (auth == null) return false;
      _userName = auth.name;
      _userSurname = auth.surname;
      _userEmail = auth.email;
      _avatarUrl = auth.avatarUrl;
      _groupName = auth.groupName;
      _institutionName = auth.institutionName;
      return true;
    } catch (e) {
      debugPrint('Ошибка fetchFullProfile: $e');
      return false;
    }
  }

  Future<void> _loadCachedProfile() async {
    final cached = await _userRepository.getCachedProfile();
    if (cached == null) return;
    _userId = cached.userId;
    _role = cached.role;
    _institutionId = cached.institutionId;
    _groupId = cached.groupId;
    _userName = cached.name;
    _userSurname = cached.surname;
    _userEmail = cached.email;
    _avatarUrl = cached.avatarUrl;
    _institutionName = cached.institutionName;
    _groupName = cached.groupName;
    debugPrint('Профиль загружен из локального кэша (офлайн-режим)');
  }

  void _setupRealtime() {
    _realtimeListener.stopListening();
    if (_role == 'student' && _userId != null && _groupId != null) {
      _realtimeListener.startListening(_userId!, _groupId!);
    } else if (_role == 'teacher' && _institutionId != null && _userId != null) {
      _realtimeListener.startListeningAsTeacher(_institutionId!, _userId!);
    }
  }

  Future<void> _scheduleHomeworkReminders() async {
    if (_role != 'student' || _userId == null) return;
    final result = await _homeworkRepository.getHomeworksForStudentGroup(_userId!, _groupId ?? '');
    if (result.isFailure) return;
    final notificationService = NotificationService();
    await notificationService.cancelAllScheduled();
    final now = DateTime.now();
    for (final hw in result.data) {
      if (hw.dueDate == null) continue;
      final reminderTime = hw.dueDate!.subtract(const Duration(hours: 24));
      if (!reminderTime.isAfter(now)) continue;
      unawaited(
        notificationService.scheduleDeadlineReminder(
          id: hw.id.hashCode.abs(),
          homeworkTitle: hw.title,
          dueDate: hw.dueDate!,
        ),
      );
    }
  }

  Future<void> loadPeriods() async {
    if (_institutionId == null) return;
    final result = await AcademicPeriodService().getPeriods(_institutionId!);
    if (result.isFailure) return;
    _periods = result.data;
    if (_periods.isEmpty) {
      _selectedPeriod = null;
    } else {
      final matching = _periods.where((p) => p.isCurrent());
      _selectedPeriod = matching.isNotEmpty ? matching.first : _periods.last;
    }
    notifyListeners();
  }

  void setSelectedPeriod(AcademicPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  Future<void> clearUser() async {
    _realtimeListener.stopListening();
    _userId = null;
    _role = null;
    _institutionId = null;
    _groupId = null;
    _userName = null;
    _userSurname = null;
    _userEmail = null;
    _avatarUrl = null;
    _institutionName = null;
    _groupName = null;
    _periods = [];
    _selectedPeriod = null;
    await Future.wait([SessionService.clearSession(), _userRepository.clearAll()]);
    notifyListeners();
  }
}
