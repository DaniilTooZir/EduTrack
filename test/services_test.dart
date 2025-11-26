import 'package:flutter_test/flutter_test.dart';

class AppUtils {
  static String generateLogin(String name, String surname) {
    if (name.isEmpty || surname.isEmpty) throw ArgumentError('Имя/Фамилия не могут быть пустыми');
    return '${name.trim()}.${surname.trim()}'.toLowerCase();
  }

  static double calculateAverageGrade(List<int> grades) {
    if (grades.isEmpty) return 0.0;
    final sum = grades.reduce((a, b) => a + b);
    final result = sum / grades.length;
    return double.parse(result.toStringAsFixed(1));
  }

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  static String formatStatus(String status) {
    switch (status) {
      case 'approved': return 'Одобрено';
      case 'rejected': return 'Отклонено';
      case 'pending': return 'В ожидании';
      default: return 'Неизвестно';
    }
  }
}

void main() {
  group('Unit-тесты: Генерация данных', () {
    test('Генерация логина: стандартный случай', () {
      final result = AppUtils.generateLogin('Ivan', 'Ivanov');
      expect(result, 'ivan.ivanov');
    });

    test('Генерация логина: защита от пробелов и разного регистра', () {
      final result = AppUtils.generateLogin('  DamiR ', 'ZYRYAEV  ');
      expect(result, 'damir.zyryaev');
    });

    test('Генерация логина: ошибка при пустых данных', () {
      expect(() => AppUtils.generateLogin('', 'Ivanov'), throwsArgumentError);
    });
  });

  group('Unit-тесты: Расчет успеваемости', () {
    test('Средний балл: список отличника', () {
      final grades = [5, 5, 5, 5];
      expect(AppUtils.calculateAverageGrade(grades), 5.0);
    });

    test('Средний балл: смешанные оценки (округление)', () {
      final grades = [5, 4, 3];
      expect(AppUtils.calculateAverageGrade(grades), 4.0);
    });

    test('Средний балл: дробный результат', () {
      final grades = [5, 4];
      expect(AppUtils.calculateAverageGrade(grades), 4.5);
    });

    test('Средний балл: пустой список', () {
      expect(AppUtils.calculateAverageGrade([]), 0.0);
    });
  });

  group('Unit-тесты: Валидация и UI', () {
    test('Email валидация: корректный email', () {
      expect(AppUtils.isValidEmail('test@study.com'), true);
    });

    test('Email валидация: некорректный email (без @)', () {
      expect(AppUtils.isValidEmail('teststudy.com'), false);
    });

    test('Форматирование статуса: перевод на русский', () {
      expect(AppUtils.formatStatus('approved'), 'Одобрено');
      expect(AppUtils.formatStatus('unknown_code'), 'Неизвестно');
    });
  });
}