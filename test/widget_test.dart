import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/ui/screens/login_screen.dart';
import 'package:edu_track/providers/user_provider.dart';

void main() {
  group('Widget-тесты: Экран авторизации (LoginScreen)', () {
    Widget createLoginScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('Проверка полной отрисовки интерфейса (Layout)', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      expect(find.text('Вход в систему'), findsOneWidget);
      expect(find.text('Логин'), findsOneWidget);
      expect(find.text('Пароль'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Войти'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
    });

    testWidgets('Проверка взаимодействия с полями ввода (Input Interaction)', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsNWidgets(2));
      final loginField = find.ancestor(
        of: find.text('Логин'),
        matching: find.byType(TextField),
      ).first;
      await tester.enterText(loginField, 'teacher_ivanov');
      expect(find.text('teacher_ivanov'), findsOneWidget);
      final passwordField = find.ancestor(
        of: find.text('Пароль'),
        matching: find.byType(TextField),
      ).first;
      await tester.enterText(passwordField, '123456');
      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets('Кнопка "Войти" реагирует на нажатие', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      final loginButton = find.widgetWithText(ElevatedButton, 'Войти');
      await tester.tap(loginButton);
      await tester.pump();
    });
  });
}
