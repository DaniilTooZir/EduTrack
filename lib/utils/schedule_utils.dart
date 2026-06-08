import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/utils/date_utils.dart';

Schedule? findNextLesson(List<Schedule> schedules) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  Schedule? best;
  DateTime? bestStart;
  for (final s in schedules) {
    if (s.date == null) continue;
    final lessonDate = DateTime(s.date!.year, s.date!.month, s.date!.day);
    if (lessonDate.isBefore(today)) continue;
    final parts = s.startTime.split(':');
    if (parts.length < 2) continue;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) continue;
    final lessonStart = DateTime(lessonDate.year, lessonDate.month, lessonDate.day, h, m);
    if (lessonDate == today && lessonStart.isBefore(now)) continue;
    if (best == null || lessonStart.isBefore(bestStart!)) {
      best = s;
      bestStart = lessonStart;
    }
  }
  return best;
}

String lessonDateLabel(Schedule s) {
  if (s.date == null) return '';
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final lessonDate = DateTime(s.date!.year, s.date!.month, s.date!.day);
  final diff = lessonDate.difference(todayDate).inDays;
  if (diff == 0) return 'Сегодня';
  if (diff == 1) return 'Завтра';
  const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  return '${days[s.date!.weekday - 1]}, ${formatShortDate(s.date!)}';
}
