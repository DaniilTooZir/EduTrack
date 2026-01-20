import 'package:edu_track/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Тестирование модуля валидации (Validators)', () {
    // Проверка реакции на пустой ввод
    test('validateEmail возвращает ошибку, если поле пустое', () {
      const String emptyInput = '';
      final result = Validators.validateEmail(emptyInput);

      expect(result, 'Введите Email');
    });

    //Проверка реакции на некорректный формат (без @)
    test('validateEmail возвращает ошибку при отсутствии символа @', () {
      const String invalidInput = 'student-example.com';
      final result = Validators.validateEmail(invalidInput);

      expect(result, 'Введите корректный Email');
    });

    //Проверка валидного ввода
    test('validateEmail возвращает null (успех) при корректном email', () {
      const String validInput = 'student@university.com';
      final result = Validators.validateEmail(validInput);

      expect(result, null);
    });
  });
}
