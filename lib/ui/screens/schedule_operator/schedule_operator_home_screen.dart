import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/schedule_operator/schedule_schedule_operator_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ScheduleOperatorHomeScreen extends StatefulWidget {
  const ScheduleOperatorHomeScreen({super.key});

  @override
  State<ScheduleOperatorHomeScreen> createState() => _ScheduleOperatorHomeScreenState();
}

class _ScheduleOperatorHomeScreenState extends State<ScheduleOperatorHomeScreen> {
  int _selectedIndex = 0;
  final List<String> _titles = ['Главная', 'Расписание'];
  final ScheduleService _scheduleService = ScheduleService();
  late Future<List<Schedule>> _scheduleFuture;
  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final institutionId = userProvider.institutionId;
    if (institutionId != null) {
      _scheduleFuture = _scheduleService.getScheduleForInstitution(institutionId);
    } else {
      _scheduleFuture = Future.error('ID учреждения не найден');
    }
  }

  void _refreshDashboard() {
    setState(() {
      _refreshKey = UniqueKey();
      _loadData();
    });
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _refreshDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;

    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = _buildDashboard(colors);
        break;
      case 1:
        bodyContent = const ScheduleScheduleOperatorScreen();
        break;
      default:
        bodyContent = _buildPlaceholder(_titles[_selectedIndex], colors);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 4,
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 0)
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить расписание', onPressed: _refreshDashboard),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              await SessionService.clearSession();
              userProvider.clearUser();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.secondary, colors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Меню оператора расписания',
                  style: TextStyle(color: colors.onPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Главная', 0, colors),
            _buildDrawerItem(Icons.edit_calendar, 'Редактор расписания', 1, colors),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: colors.onSurfaceVariant),
              title: Text('Настройки', style: TextStyle(color: colors.onSurface)),
              onTap: () {
                Navigator.pop(context);
                showSettingsSheet(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: bodyContent,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, ColorScheme colors) {
    final bool selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? colors.primary : colors.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? colors.primary : colors.onSurface,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: colors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      onTap: () {
        _navigateToTab(index);
        Navigator.of(context).pop();
      },
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  String _getWeekdayName(int weekday) {
    const days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    if (weekday >= 1 && weekday <= 7) return days[weekday - 1];
    return 'Неизвестно';
  }

  Widget _buildDashboard(ColorScheme colors) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshDashboard();
        await Future.delayed(const Duration(seconds: 1));
      },
      color: colors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(colors),
            const SizedBox(height: 24),
            Text('Действия', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToTab(1),
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Перейти к редактированию расписания'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.surface,
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Полное расписание',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
            ),
            const SizedBox(height: 4),
            Text('Группировка по дням и датам.', style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
            const SizedBox(height: 12),
            FutureBuilder<List<Schedule>>(
              key: _refreshKey,
              future: _scheduleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}', style: TextStyle(color: colors.error)));
                }
                final schedules = snapshot.data ?? [];
                if (schedules.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Расписание пусто.', style: TextStyle(color: colors.onSurfaceVariant)),
                    ),
                  );
                }
                schedules.sort((a, b) {
                  if (a.date == null && b.date != null) return -1;
                  if (a.date != null && b.date == null) return 1;
                  if (a.date != null && b.date != null) {
                    final dateComp = a.date!.compareTo(b.date!);
                    if (dateComp != 0) return dateComp;
                  }
                  final dayComp = a.weekday.compareTo(b.weekday);
                  if (dayComp != 0) return dayComp;
                  return a.startTime.compareTo(b.startTime);
                });
                final Map<String, List<Schedule>> grouped = {};
                for (final s in schedules) {
                  String header;
                  final String dayName = _getWeekdayName(s.weekday);
                  if (s.date != null) {
                    header = '$dayName, ${_formatDate(s.date!)}';
                  } else {
                    header = dayName;
                  }
                  grouped.putIfAbsent(header, () => []).add(s);
                }
                return Column(
                  children:
                      grouped.entries.map((entry) {
                        return _buildDayScheduleCard(entry.key, entry.value, colors);
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.secondary, colors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: colors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Панель управления',
            style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Добро пожаловать, Оператор. Здесь вы можете просматривать и корректировать учебное расписание.',
            style: TextStyle(color: colors.onPrimary.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDayScheduleCard(String headerTitle, List<Schedule> dailySchedules, ColorScheme colors) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.calendar_today, color: colors.onPrimaryContainer, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(headerTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.primary)),
                ],
              ),
            ),
            const Divider(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowHeight: 40,
                columns: [
                  DataColumn(
                    label: Text('Время', style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
                  ),
                  DataColumn(
                    label: Text('Группа', style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
                  ),
                  DataColumn(
                    label: Text('Предмет', style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
                  ),
                  DataColumn(
                    label: Text(
                      'Преподаватель',
                      style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
                    ),
                  ),
                ],
                rows:
                    dailySchedules.map((schedule) {
                      final timeStr = '${schedule.startTime.substring(0, 5)} - ${schedule.endTime.substring(0, 5)}';
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(timeStr, style: TextStyle(fontWeight: FontWeight.w500, color: colors.onSurface)),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                schedule.groupName ?? '—',
                                style: TextStyle(color: colors.onSecondaryContainer),
                              ),
                            ),
                          ),
                          DataCell(Text(schedule.subjectName ?? '—', style: TextStyle(color: colors.onSurface))),
                          DataCell(Text(schedule.teacherName, style: TextStyle(fontSize: 14, color: colors.onSurface))),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title, ColorScheme colors) {
    return Center(
      child: Text(
        '$title — экран в разработке',
        style: TextStyle(fontSize: 18, color: colors.primary, fontWeight: FontWeight.w500),
      ),
    );
  }
}
