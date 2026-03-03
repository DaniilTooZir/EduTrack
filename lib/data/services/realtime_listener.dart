import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeListener {
  final _client = SupabaseConnection.client;
  final _notificationService = NotificationService();
  RealtimeChannel? _gradesChannel;
  RealtimeChannel? _homeworkChannel;

  // Запуск прослушивания
  void startListening(String studentId, String groupId) {
    _listenToGrades(studentId);
    _listenToHomework(groupId);
  }

  void stopListening() {
    if (_gradesChannel != null) _client.removeChannel(_gradesChannel!);
    if (_homeworkChannel != null) _client.removeChannel(_homeworkChannel!);
  }

  void _listenToGrades(String studentId) {
    _gradesChannel =
        _client
            .channel('public:grade:$studentId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'grade',
              filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'student_id', value: studentId),
              callback: (payload) {
                final val = payload.newRecord['value'];
                _notificationService.showNotification(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: 'Новая оценка!',
                  body: 'Вы получили оценку: $val',
                );
              },
            )
            .subscribe();
  }

  void _listenToHomework(String groupId) {
    _homeworkChannel =
        _client
            .channel('public:homework:$groupId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'homework',
              filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'group_id', value: groupId),
              callback: (payload) {
                final title = payload.newRecord['title'];
                _notificationService.showNotification(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: 'Новое домашнее задание',
                  body: '$title',
                );
              },
            )
            .subscribe();
  }
}
