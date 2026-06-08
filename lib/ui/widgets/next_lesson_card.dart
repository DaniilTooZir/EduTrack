import 'package:edu_track/models/schedule.dart';
import 'package:flutter/material.dart';

class NextLessonCard extends StatelessWidget {
  const NextLessonCard({
    super.key,
    required this.lesson,
    required this.dateLabel,
    required this.detailIcon,
    required this.detailText,
  });

  final Schedule lesson;
  final String dateLabel;
  final IconData detailIcon;
  final String detailText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isToday = dateLabel == 'Сегодня';
    final accentColor = isToday ? colors.primary : colors.secondary;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            dateLabel,
                            style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.access_time_rounded, size: 15, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.startTime.substring(0, 5)} – ${lesson.endTime.substring(0, 5)}',
                          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lesson.subjectName ?? 'Предмет',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(detailIcon, size: 15, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(detailText, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
