import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:edu_track/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Сквозной тест подачи и проверки заявки', () {
    testWidgets('Пользователь подает заявку и проверяет ее статус', (WidgetTester tester) async {
      // Запуск приложения
      app.main();

      await tester.pumpAndSettle();

      // Поиска и нажатие на кнопку "Зарегистрировать ОО"
      final registerButton = find.text('Зарегистрировать ОО');
      expect(registerButton, findsOneWidget);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Заполнение формы регистрации
      await tester.enterText(find.widgetWithText(TextFormField, 'Название организации'), 'Тестовый Университет');
      await tester.enterText(find.widgetWithText(TextFormField, 'Адрес организации'), 'г. Тестовый, ул. Программная, 1');
      await tester.enterText(find.widgetWithText(TextFormField, 'Имя руководителя'), 'Иван');
      await tester.enterText(find.widgetWithText(TextFormField, 'Фамилия руководителя'), 'Тестеров');

      final uniqueEmail = 'test-${DateTime.now().millisecondsSinceEpoch}@test.com';
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), uniqueEmail);

      // Отправка заявки
      final submitButton = find.text('Отправить заявку');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Переход на экран проверки статуса
      final checkStatusButton = find.text('Проверить статус заявки');
      expect(checkStatusButton, findsOneWidget);
      await tester.tap(checkStatusButton);
      await tester.pumpAndSettle();

      // Ввод email и проверка статуса
      final emailField = find.widgetWithText(TextFormField, 'Email руководителя');
      expect(emailField, findsOneWidget);
      await tester.enterText(emailField, uniqueEmail);
      final checkButton = find.text('Проверить статус');
      expect(checkButton, findsOneWidget);
      await tester.tap(checkButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Заявка находится на рассмотрении.'), findsOneWidget);
    });
  });
}