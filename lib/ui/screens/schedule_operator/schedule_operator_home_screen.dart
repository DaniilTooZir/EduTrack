import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/screens/schedule_operator/schedule_schedule_operator_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/drawer_nav_item.dart';
import 'package:edu_track/ui/widgets/settings_sheet.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/ui/widgets/welcome_card.dart';
import 'package:edu_track/utils/data_loading_mixin.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ScheduleOperatorHomeScreen extends StatefulWidget {
  const ScheduleOperatorHomeScreen({super.key});

  @override
  State<ScheduleOperatorHomeScreen> createState() => _ScheduleOperatorHomeScreenState();
}

class _ScheduleOperatorHomeScreenState extends State<ScheduleOperatorHomeScreen> with DataLoadingMixin {
  int _selectedIndex = 0;
  final List<String> _titles = ['Главная', 'Расписание'];
  ScheduleRepository get _scheduleService => Provider.of<ScheduleRepository>(context, listen: false);
  List<Schedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) return;
    await loadAsync(_scheduleService.getScheduleForInstitution(institutionId), onSuccess: (data) => _schedules = data);
  }

  void _refreshDashboard() {
    _loadData();
  }

  void _navigateToTab(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _loadData();
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
              await userProvider.clearUser();
              if (context.mounted) context.go(AppRoutes.welcome);
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
            DrawerNavItem(
              icon: Icons.dashboard,
              title: 'Главная',
              selected: _selectedIndex == 0,
              onTap: () {
                _navigateToTab(0);
                Navigator.of(context).pop();
              },
            ),
            DrawerNavItem(
              icon: Icons.edit_calendar,
              title: 'Редактор расписания',
              selected: _selectedIndex == 1,
              onTap: () {
                _navigateToTab(1);
                Navigator.of(context).pop();
              },
            ),
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

  String _getWeekdayName(int weekday) {
    const days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    if (weekday >= 1 && weekday <= 7) return days[weekday - 1];
    return 'Неизвестно';
  }

  Widget _buildDashboard(ColorScheme colors) {
    final sorted = List<Schedule>.from(_schedules)..sort((a, b) {
      if (a.date == null && b.date != null) return -1;
      if (a.date != null && b.date == null) return 1;
      if (a.date != null && b.date != null) {
        final d = a.date!.compareTo(b.date!);
        if (d != 0) return d;
      }
      final w = a.weekday.compareTo(b.weekday);
      if (w != 0) return w;
      return a.startTime.compareTo(b.startTime);
    });
    final grouped = <String, List<Schedule>>{};
    for (final s in sorted) {
      final header =
          s.date != null ? '${_getWeekdayName(s.weekday)}, ${formatDate(s.date!)}' : _getWeekdayName(s.weekday);
      grouped.putIfAbsent(header, () => []).add(s);
    }
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
            const WelcomeCard(
              title: 'Панель управления',
              subtitle:
                  'Добро пожаловать, Оператор. Здесь вы можете просматривать и корректировать учебное расписание.',
              useSecondaryGradient: true,
            ),
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
            if (isLoading)
              _buildScheduleSkeleton(colors)
            else if (_schedules.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Расписание пусто.', style: TextStyle(color: colors.onSurfaceVariant)),
                ),
              )
            else
              Column(children: grouped.entries.map((e) => _buildDayScheduleCard(e.key, e.value, colors)).toList()),
          ],
        ),
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

  Widget _buildScheduleSkeleton(ColorScheme colors) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Skeleton(height: 36, width: 36, borderRadius: 8),
                      SizedBox(width: 12),
                      Skeleton(height: 18, width: 160),
                    ],
                  ),
                ),
                const Divider(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Skeleton(height: 13, width: 65),
                            SizedBox(width: 20),
                            Skeleton(height: 13, width: 55),
                            SizedBox(width: 20),
                            Skeleton(height: 13, width: 100),
                            SizedBox(width: 20),
                            Skeleton(height: 13, width: 120),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
