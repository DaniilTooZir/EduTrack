import 'dart:async';
import 'package:edu_track/data/services/institution_request_moderation_service.dart';

class ModerationTimer {
  static Timer? _timer;
  static void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await InstitutionModerationService.processPendingRequests();
    });
  }
  static void stop() {
    _timer?.cancel();
  }
}