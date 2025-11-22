import 'dart:math';
import 'package:edu_track/data/database/connection_to_database.dart';

/// Сервис для автоматической модерации заявок образовательных организаций.
/// Обрабатывает заявки в статусе `pending` и создаёт аккаунты руководителей.
class InstitutionModerationService {
  /// Основной метод: получает все заявки в ожидании и обрабатывает каждую.
  static Future<void> processPendingRequests() async {
    try {
      // Запрашивает все заявки со статусом pending
      final pendingRequests = await SupabaseConnection.client
          .from('institution_requests')
          .select()
          .eq('status', 'pending');
      for (final request in pendingRequests) {
        await _processSingleRequest(request);
      }
    } catch (e, stack) {
      print('Глобальная ошибка в processPendingRequests: $e');
      print(stack);
    }
  }

  /// Обрабатывает одну заявку: проверяет существование администратора,
  /// создаёт новое учреждение и администратора или отклоняет заявку.
  static Future<void> _processSingleRequest(Map<String, dynamic> request) async {
    final email = request['email'];
    try {
      // Проверяка, существует ли уже администратор с таким email
      final existingAdmin = await SupabaseConnection.client.from('education_heads').select().eq('email', email);
      if (existingAdmin.isEmpty) {
        final login = _generateLogin(request['head_name'], request['head_surname']);
        final password = _generatePassword();

        // Создание запись учреждения и получаем ID
        final institutionInsert =
            await SupabaseConnection.client
                .from('institutions')
                .insert({'name': request['name'], 'address': request['address']})
                .select('id')
                .single();
        final institutionId = institutionInsert['id'];

        // Создание администратора (руководителя учреждения)
        await SupabaseConnection.client.from('education_heads').insert({
          'name': request['head_name'],
          'surname': request['head_surname'],
          'email': email,
          'login': login,
          'password': password,
          'institution_id': institutionId,
          'phone': request['phone'],
        });

        // обработка статуса заявки
        await _updateRequestStatus(request['id'], 'approved');
        print('Заявка одобрена для $email. Логин: $login, Пароль: $password');
      } else {
        await _updateRequestStatus(request['id'], 'rejected');
        print('Заявка отклонена — аккаунт с таким email уже существует: $email');
      }
    } catch (e, stack) {
      print('Ошибка при обработке заявки для $email: $e');
      print(stack);
      await _updateRequestStatus(request['id'], 'failed');
    }
  }

  /// Обновление статуса заявки
  static Future<void> _updateRequestStatus(String id, String status) async {
    await SupabaseConnection.client.from('institution_requests').update({'status': status}).eq('id', id);
  }

  /// Генерация логина: имя.фамилия + случайные 4 цифры.
  static String _generateLogin(String firstName, String lastName) {
    final randomNumber = Random().nextInt(9000) + 1000;
    return '${firstName.toLowerCase()}.${lastName.toLowerCase()}$randomNumber';
  }

  /// Генерация безопасного пароля.
  static String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%';
    final rand = Random.secure();
    return List.generate(
      12,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
