import 'package:edu_track/data/services/lesson_service.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StudentLessonScreen extends StatefulWidget {
  const StudentLessonScreen({super.key});

  @override
  State<StudentLessonScreen> createState() => _StudentLessonScreenState();
}

class _StudentLessonScreenState extends State<StudentLessonScreen> {
  final LessonService _lessonService = LessonService();
  final ScheduleService _scheduleService = ScheduleService();

  bool _loading = true;
  List<Lesson> _lessons = [];
  String? get studentId => Provider.of<UserProvider>(context, listen: false).userId;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    if (studentId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final schedules = await _scheduleService.getScheduleForStudent(studentId!);
      final List<Lesson> allLessons = [];
      for (final schedule in schedules) {
        final lessons = await _lessonService.getLessonsByScheduleId(schedule.id);
        allLessons.addAll(lessons);
      }
      allLessons.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      if (mounted) {
        setState(() {
          _lessons = allLessons;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке уроков: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildLessonCard(Lesson lesson) {
    return FutureBuilder<Schedule?>(
      future: _scheduleService.getScheduleById(lesson.scheduleId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Container(
              height: 100,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final schedule = snapshot.data!;
        final subjectName = schedule.subject?.name ?? 'Предмет';
        final date = schedule.date;
        final day = date != null ? date.day.toString().padLeft(2, '0') : '--';
        final month = date != null ? _getMonthName(date.month) : '';
        final timeStr = '${schedule.startTime.substring(0, 5)} - ${schedule.endTime.substring(0, 5)}';
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/student/lesson_comments', extra: lesson.id),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD1C4E9)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            day,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5E35B1)),
                          ),
                          Text(
                            month,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF7E57C2)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subjectName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade300,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.topic ?? 'Без темы',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(timeStr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade50),
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, size: 20),
                        color: const Color(0xFF5E35B1),
                        tooltip: 'Открыть чат',
                        onPressed: () {
                          context.push('/student/lesson_comments', extra: lesson.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _lessons.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.class_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Пока нет проведенных уроков', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  itemCount: _lessons.length,
                  itemBuilder: (context, index) => _buildLessonCard(_lessons[index]),
                ),
      ),
    );
  }
}
