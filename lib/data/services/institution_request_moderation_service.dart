import 'dart:math';
import 'package:edu_track/data/database/connection_to_database.dart';

/// Сервис для автоматической модерации заявок образовательных организаций.
/// Обрабатывает заявки в статусе `pending` и создаёт аккаунты руководителей.
class InstitutionModerationService {
  /// Основной метод: получает все заявки в ожидании и обрабатывает каждую.
  static Future<void> processPendingRequests() async {
    try {
      // Запрашиваем все заявки со статусом pending
      final pendingRequests = await SupabaseConnection.client
          .from('institution_requests')
          .select()
          .eq('status', 'pending');

      // Перебираем каждую заявку
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
      // Проверяем, существует ли уже администратор с таким email
      final existingAdmin = await SupabaseConnection.client.from('education_heads').select().eq('email', email);
      if (existingAdmin.isEmpty) {
        // Генерируем учётные данные для руководителя
        final login = _generateLogin(request['head_name'], request['head_surname']);
        final password = _generatePassword();

        // Создаём запись учреждения и получаем ID
        final institutionInsert =
            await SupabaseConnection.client
                .from('institutions')
                .insert({'name': request['name'], 'address': request['address']})
                .select('id')
                .single();
        final institutionId = institutionInsert['id'];

        // Создаём администратора (руководителя учреждения)
        await SupabaseConnection.client.from('education_heads').insert({
          'name': request['head_name'],
          'surname': request['head_surname'],
          'email': email,
          'login': login,
          'password': password,
          'institution_id': institutionId,
          'phone': request['phone'],
        });

        // Обновляем статус заявки
        await _updateRequestStatus(request['id'], 'approved');
        print('Заявка одобрена для $email. Логин: $login, Пароль: $password');
      } else {
        // Отклоняем заявку из-за существующего аккаунта
        await _updateRequestStatus(request['id'], 'rejected');

        print('Заявка отклонена — аккаунт с таким email уже существует: $email');
      }
    } catch (e, stack) {
      print('Ошибка при обработке заявки для $email: $e');
      print(stack);

      // Помечаем как failed, если что-то пошло не так
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
      12, // чуть длиннее — безопаснее
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
