import 'package:edu_track/models/grade.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Тестирование модуля успеваемости (Grade Module)', () {
    test('Маппинг модели Grade должен корректно преобразовывать JSON из БД', () {
      final map = {'id': 'test-uuid-123', 'lessons_id': 'lesson-456', 'student_id': 'student-789', 'value': 5};
      final grade = Grade.fromMap(map);
      expect(grade.id, 'test-uuid-123');
      expect(grade.lessonId, 'lesson-456');
      expect(grade.value, 5);
      final backToMap = grade.toMap();
      expect(backToMap['id'], 'test-uuid-123');
      expect(backToMap['value'], 5);
    });

    test('Метод calculateGPA должен верно вычислять среднее арифметическое', () {
      final grades = [
        Grade(lessonId: '1', studentId: 's1', value: 5),
        Grade(lessonId: '2', studentId: 's1', value: 3),
        Grade(lessonId: '3', studentId: 's1', value: 4),
      ];
      final gpa = Grade.calculateGPA(grades);
      expect(gpa, 4.0);
    });

    test('calculateGPA для пустого списка оценок должен возвращать 0.0', () {
      final gpa = Grade.calculateGPA([]);
      expect(gpa, 0.0);
    });

    test('AppResult должен корректно инкапсулировать данные при успехе', () {
      const testData = 'Success data';
      final result = AppResult<String>.success(testData);
      expect(result.isSuccess, true);
      expect(result.data, testData);
      expect(result.isFailure, false);
    });

    test('AppResult должен корректно хранить сообщение об ошибке при провале', () {
      const errorMessage = 'Ошибка сети';
      final result = AppResult<void>.failure(errorMessage);
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.errorMessage, errorMessage);
    });
  });
}
