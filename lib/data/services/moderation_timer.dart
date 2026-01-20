import 'dart:async';

import 'package:edu_track/data/services/institution_request_moderation_service.dart';
import 'package:flutter/foundation.dart';

class ModerationTimer {
  static Timer? _timer;
  static bool _isProcessing = false;

  static void start() {
    if (_timer != null && _timer!.isActive) {
      debugPrint('[ModerationTimer] Таймер уже работает.');
      return;
    }
    debugPrint('[ModerationTimer] Запуск таймера модерации...');

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _tick();
    });
  }

  static Future<void> _tick() async {
    if (_isProcessing) {
      debugPrint('[ModerationTimer] Предыдущая задача еще выполняется. Пропуск такта.');
      return;
    }
    _isProcessing = true;
    try {
      debugPrint('[ModerationTimer] Проверка новых заявок...');
      await InstitutionModerationService.processPendingRequests();
      debugPrint('[ModerationTimer] Модерация заявок завершена успешно.');
    } catch (e, stackTrace) {
      debugPrint('[ModerationTimer] Ошибка во время модерации: $e');
      debugPrint('[ModerationTimer] StackTrace: $stackTrace');
    } finally {
      _isProcessing = false;
    }
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _isProcessing = false;
    debugPrint('[ModerationTimer] Таймер остановлен.');
  }
}
