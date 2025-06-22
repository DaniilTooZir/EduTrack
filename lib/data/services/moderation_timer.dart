import 'dart:async';
import 'package:edu_track/data/services/institution_request_moderation_service.dart';

class ModerationTimer {
  static Timer? _timer;

  static void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      try {
        print('[ModerationTimer] Проверка новых заявок...');
        await InstitutionModerationService.processPendingRequests();
        print('[ModerationTimer] Модерация заявок завершена успешно.');
      } catch (e, stackTrace) {
        print('[ModerationTimer] Ошибка во время модерации: $e');
        print('[ModerationTimer] StackTrace: $stackTrace');
      }
    });
  }

  static void stop() {
    _timer?.cancel();
    print('[ModerationTimer] Таймер остановлен.');
  }
}