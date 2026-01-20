import 'package:flutter_test/flutter_test.dart';

class RegistrationLogic {
  static String generateHeadLogin(String name, String surname) {
    if (name.isEmpty || surname.isEmpty) {
      throw ArgumentError('Имя/Фамилия не могут быть пустыми');
    }
    return '${name.trim()}.${surname.trim()}'.toLowerCase();
  }

  static bool validateContactEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  static String localizeStatus(String dbStatus) {
    switch (dbStatus) {
      case 'approved':
        return 'Одобрено';
      case 'rejected':
        return 'Отклонено';
      case 'pending':
        return 'В ожидании';
      default:
        return 'Неизвестно';
    }
  }
}

void main() {
  group('Тест сценария 5: Генерация и валидация данных регистрации', () {
    test('Генерация логина: стандартный случай', () {
      final result = RegistrationLogic.generateHeadLogin('Ivan', 'Ivanov');
      expect(result, 'ivan.ivanov');
    });

    test('Генерация логина: защита от пробелов и разного регистра', () {
      final result = RegistrationLogic.generateHeadLogin('  DamiR ', 'ZYRYAEV  ');
      expect(result, 'damir.zyryaev');
    });

    test('Генерация логина: обработка пустых данных', () {
      expect(() => RegistrationLogic.generateHeadLogin('', 'Ivanov'), throwsArgumentError);
    });

    test('Валидация Email: корректный адрес', () {
      expect(RegistrationLogic.validateContactEmail('admin@school.com'), true);
    });

    test('Валидация Email: защита от некорректного формата', () {
      expect(RegistrationLogic.validateContactEmail('adminschool.com'), false);
    });

    test('Обработка статуса: перевод статуса "pending" из БД', () {
      expect(RegistrationLogic.localizeStatus('pending'), 'В ожидании');
    });

    test('Обработка статуса: неизвестный статус', () {
      expect(RegistrationLogic.localizeStatus('unknown_error'), 'Неизвестно');
    });
  });
}
