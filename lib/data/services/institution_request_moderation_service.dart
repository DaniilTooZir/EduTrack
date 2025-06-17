import 'dart:math';
import 'package:edu_track/data/database/connection_to_database.dart';

class InstitutionModerationService {
  static Future<void> processPendingRequests() async {
    final pendingRequests = await SupabaseConnection.client
        .from('institution_requests')
        .select()
        .eq('status', 'pending');

    for (final request in pendingRequests) {
      final email = request['email'];
      final existingAdmin = await SupabaseConnection.client
          .from('education_heads')
          .select()
          .eq('email', email);

      if (existingAdmin.isEmpty) {
        final login = _generateLogin(request['head_name'], request['head_surname']);
        final password = _generatePassword();
        final institutionInsert = await SupabaseConnection.client
            .from('institutions')
            .insert({
          'name': request['name'],
          'address': request['address'],
        })
            .select('id')
            .single();
        final institutionId = institutionInsert['id'];

        await SupabaseConnection.client
            .from('education_heads')
            .insert({
          'name': request['head_name'],
          'surname': request['head_surname'],
          'email': email,
          'login': login,
          'password': password,
          'institution_id': institutionId,
          'phone': request['phone'],
        });

        await SupabaseConnection.client
            .from('institution_requests')
            .update({'status': 'approved'})
            .eq('id', request['id']);

        // Вывод логина и пароля в консоль (в будущем отправка по email)
        print("Заявка одобрена: логин: $login, пароль: $password");
      } else {
        await SupabaseConnection.client
            .from('institution_requests')
            .update({'status': 'rejected'})
            .eq('id', request['id']);
      }
    }
  }

  static String _generateLogin(String firstName, String lastName) {
    final randomNumber = Random().nextInt(9000) + 1000;
    return '${firstName.toLowerCase()}.${lastName.toLowerCase()}$randomNumber';
  }

  static String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%';
    final rand = Random.secure();
    return List.generate(10, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}