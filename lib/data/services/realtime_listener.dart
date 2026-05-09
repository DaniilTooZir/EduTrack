import 'dart:async';

import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeListener {
  final _client = SupabaseConnection.client;
  final _notificationService = NotificationService();
  RealtimeChannel? _gradesChannel;
  RealtimeChannel? _homeworkChannel;
  RealtimeChannel? _homeworkSubmissionsChannel;
  RealtimeChannel? _scheduleChannel;
  RealtimeChannel? _chatChannel;
  Set<String> _userChatIds = {};

  // Запуск прослушивания для студента
  void startListening(String studentId, String groupId) {
    stopListening();
    _listenToGrades(studentId);
    _listenToHomework(groupId);
    _listenToScheduleChanges(groupId: groupId);
    unawaited(_listenToChatMessages(studentId));
  }

  // Запуск прослушивания для преподавателя
  void startListeningAsTeacher(String institutionId, String teacherId) {
    stopListening();
    _listenToHomeworkSubmissions(institutionId);
    _listenToScheduleChanges(teacherId: teacherId);
    unawaited(_listenToChatMessages(teacherId));
  }

  void stopListening() {
    if (_gradesChannel != null) {
      _client.removeChannel(_gradesChannel!);
      _gradesChannel = null;
    }
    if (_homeworkChannel != null) {
      _client.removeChannel(_homeworkChannel!);
      _homeworkChannel = null;
    }
    if (_homeworkSubmissionsChannel != null) {
      _client.removeChannel(_homeworkSubmissionsChannel!);
      _homeworkSubmissionsChannel = null;
    }
    if (_scheduleChannel != null) {
      _client.removeChannel(_scheduleChannel!);
      _scheduleChannel = null;
    }
    if (_chatChannel != null) {
      _client.removeChannel(_chatChannel!);
      _chatChannel = null;
    }
  }

  void _listenToGrades(String studentId) {
    _gradesChannel =
        _client
            .channel('public:grade:$studentId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'grade',
              filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'student_id', value: studentId),
              callback: (payload) {
                if (payload.eventType != PostgresChangeEvent.insert &&
                    payload.eventType != PostgresChangeEvent.update) {
                  return;
                }
                final val = payload.newRecord['value'];
                final isUpdate = payload.eventType == PostgresChangeEvent.update;
                _notificationService.showNotification(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: isUpdate ? 'Оценка изменена' : 'Новая оценка!',
                  body: 'Оценка: $val',
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
                final title = payload.newRecord['title']?.toString() ?? 'Домашнее задание';
                _notificationService.showNotification(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: 'Новое домашнее задание',
                  body: title,
                );
                final dueDateRaw = payload.newRecord['due_date']?.toString();
                final dueDate = dueDateRaw != null ? DateTime.tryParse(dueDateRaw) : null;
                if (dueDate != null) {
                  final reminderId = payload.newRecord['id'].toString().hashCode.abs();
                  unawaited(
                    _notificationService.scheduleDeadlineReminder(
                      id: reminderId,
                      homeworkTitle: title,
                      dueDate: dueDate,
                    ),
                  );
                }
              },
            )
            .subscribe();
  }

  void _listenToScheduleChanges({String? groupId, String? teacherId}) {
    assert(groupId != null || teacherId != null);
    final isStudent = groupId != null;
    final filterId = isStudent ? groupId : teacherId!;
    final filterColumn = isStudent ? 'group_id' : 'teacher_id';
    final channelName = isStudent ? 'public:schedule:group:$filterId' : 'public:schedule:teacher:$filterId';
    _scheduleChannel =
        _client
            .channel(channelName)
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'schedule',
              filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: filterColumn, value: filterId),
              callback: (payload) {
                final startTime = payload.newRecord['start_time'] ?? '';
                _notificationService.showNotification(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: 'Изменение в расписании',
                  body: startTime.isNotEmpty ? 'Занятие в $startTime было изменено' : 'Одно из занятий было изменено',
                );
              },
            )
            .subscribe();
  }

  Future<void> _listenToChatMessages(String userId) async {
    try {
      final rows = await _client.from('chat_members').select('chat_id').eq('user_id', userId);
      _userChatIds = {for (final row in rows) row['chat_id'] as String};
    } catch (_) {
      _userChatIds = {};
    }
    _chatChannel =
        _client
            .channel('public:messages:$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'messages',
              callback: (payload) {
                final senderId = payload.newRecord['sender_id'];
                if (senderId == userId) return;
                final chatId = payload.newRecord['chat_id']?.toString() ?? '';
                if (_userChatIds.isNotEmpty && !_userChatIds.contains(chatId)) return;
                final content = payload.newRecord['content']?.toString() ?? '';
                final fileName = payload.newRecord['file_name']?.toString() ?? '';
                final body =
                    content.isNotEmpty
                        ? content
                        : fileName.isNotEmpty
                        ? 'Прикреплён файл: $fileName'
                        : 'Новое сообщение';
                _notificationService.showNotification(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: 'Новое сообщение',
                  body: body,
                );
              },
            )
            .subscribe();
  }

  void _listenToHomeworkSubmissions(String institutionId) {
    _homeworkSubmissionsChannel =
        _client
            .channel('public:homework_status:$institutionId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'homework_status',
              callback: (payload) {
                final eventType = payload.eventType;
                if (eventType != PostgresChangeEvent.insert && eventType != PostgresChangeEvent.update) {
                  return;
                }
                final isCompleted = payload.newRecord['is_completed'];
                if (isCompleted != true) return;
                final studentId = payload.newRecord['student_id'] ?? 'неизвестен';
                final isResubmission = eventType == PostgresChangeEvent.update;
                _notificationService.showNotification(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: isResubmission ? 'Решение обновлено' : 'Студент сдал домашнее задание',
                  body: 'Студент: $studentId',
                );
              },
            )
            .subscribe();
  }
}
