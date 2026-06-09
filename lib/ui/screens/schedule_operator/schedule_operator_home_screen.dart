import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/models/academic_period.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/screens/schedule_operator/schedule_schedule_operator_screen.dart';
import 'package:edu_track/ui/screens/schedule_operator/time_grids_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/app_drawer.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/ui/widgets/stat_card.dart';
import 'package:edu_track/ui/widgets/welcome_card.dart';
import 'package:edu_track/utils/app_constants.dart';
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
  final List<String> _titles = ['Главная', 'Расписание', 'Сетки времени'];
  ScheduleRepository get _scheduleService => Provider.of<ScheduleRepository>(context, listen: false);
  List<Schedule> _schedules = [];
  AcademicPeriod? _lastPeriod;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final period = Provider.of<UserProvider>(context, listen: false).selectedPeriod;
    if (period != _lastPeriod) {
      _lastPeriod = period;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final institutionId = userProvider.institutionId;
    if (institutionId == null) return;
    final period = userProvider.selectedPeriod;
    await loadAsync(
      _scheduleService.getScheduleForInstitution(institutionId, startDate: period?.startDate, endDate: period?.endDate),
      onSuccess: (data) => _schedules = data,
    );
  }

  int get _thisWeekCount {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _schedules.where((s) => s.date != null && !s.date!.isBefore(weekStart) && s.date!.isBefore(weekEnd)).length;
  }

  List<Schedule> get _upcomingLessons {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return (_schedules.where((s) => s.date != null && !s.date!.isBefore(today)).toList()..sort((a, b) {
      final d = a.date!.compareTo(b.date!);
      return d != 0 ? d : a.startTime.compareTo(b.startTime);
    }));
  }

  void _refreshDashboard() => _loadData();

  void _navigateToTab(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _loadData();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Выход из аккаунта'),
            content: const Text('Вы уверены, что хотите выйти?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Отмена')),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
                child: const Text('Выйти'),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    await Provider.of<UserProvider>(context, listen: false).clearUser();
    if (context.mounted) context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
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
      case 2:
        bodyContent = const TimeGridsScreen();
        break;
      default:
        bodyContent = const SizedBox.shrink();
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
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить', onPressed: _refreshDashboard),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Выйти', onPressed: () => _confirmLogout(context)),
        ],
      ),
      drawer: AppDrawer(
        title: 'Меню оператора расписания',
        selectedIndex: _selectedIndex,
        onNavigate: _navigateToTab,
        items: const [
          AppDrawerItem(icon: Icons.dashboard, title: 'Главная', tabIndex: 0),
          AppDrawerItem(icon: Icons.edit_calendar, title: 'Редактор расписания', tabIndex: 1),
          AppDrawerItem(icon: Icons.schedule, title: 'Сетки времени', tabIndex: 2),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(themeProvider.effectiveMode(Theme.of(context).brightness)),
        ),
        child: bodyContent,
      ),
    );
  }

  Widget _buildDashboard(ColorScheme colors) {
    return RefreshIndicator(
      onRefresh: () async => _refreshDashboard(),
      color: colors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeCard(
              title: 'Панель управления',
              subtitle: 'Просматривайте и корректируйте учебное расписание.',
              useSecondaryGradient: true,
            ),
            const SizedBox(height: 24),
            if (isLoading)
              _buildStatsSkeleton(colors)
            else ...[
              Text('Статистика', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.primary)),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.event_note_outlined,
                      title: 'Занятий в периоде',
                      value: '${_schedules.length}',
                      iconColor: colors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: StatCard(
                      icon: Icons.date_range_outlined,
                      title: 'На этой неделе',
                      value: '$_thisWeekCount',
                      iconColor: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Ближайшие занятия',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.primary),
              ),
              const SizedBox(height: AppSpacing.m),
              if (_upcomingLessons.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('Нет предстоящих занятий.', style: TextStyle(color: colors.onSurfaceVariant)),
                  ),
                )
              else
                ...(_upcomingLessons.take(5).map((s) => _buildUpcomingCard(s, colors))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(Schedule s, ColorScheme colors) {
    final timeStr = '${s.startTime.substring(0, 5)}–${s.endTime.substring(0, 5)}';
    final dateLabel = s.date != null ? formatDate(s.date!) : _weekdayName(s.weekday);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(8)),
          child: Text(
            timeStr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colors.onPrimaryContainer),
          ),
        ),
        title: Text(s.subjectName ?? '—', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${s.groupName ?? '—'} · ${s.teacherName}'),
        trailing: Text(dateLabel, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
      ),
    );
  }

  Widget _buildStatsSkeleton(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Skeleton(height: 18, width: 120),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: const [
            Expanded(child: Skeleton(height: 88, borderRadius: 16)),
            SizedBox(width: AppSpacing.m),
            Expanded(child: Skeleton(height: 88, borderRadius: 16)),
          ],
        ),
        const SizedBox(height: 24),
        const Skeleton(height: 18, width: 160),
        const SizedBox(height: AppSpacing.m),
        for (var i = 0; i < 3; i++) ...[const Skeleton(height: 72, borderRadius: 16), const SizedBox(height: 8)],
      ],
    );
  }

  String _weekdayName(int weekday) {
    const days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    if (weekday >= 1 && weekday <= 7) return days[weekday - 1];
    return '—';
  }
}
