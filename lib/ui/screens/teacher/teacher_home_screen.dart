import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/screens/chat_list_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_homework_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_homework_status_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_lesson_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_my_group_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_profile_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_schedule_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/settings_sheet.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  List<Subject> _subjects = [];
  final List<String> _titles = [
    'Главная',
    'Домашние задания',
    'Мои занятия',
    'Расписание',
    'Профиль',
    'Проверка ДЗ',
    'Моя группа',
  ];

  Future<void> _loadData() async {
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
    if (teacherId == null) return;
    if (mounted)
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    try {
      final subjects = await SubjectService().getSubjectsByTeacherId(teacherId);
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки дашборда: $e');
      if (mounted)
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _refreshDashboard() {
    _loadData();
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
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
        bodyContent =
            _isLoading
                ? _buildTeacherHomeSkeleton()
                : _hasError
                ? _buildErrorState(colors)
                : _buildDashboard(colors);
        break;
      case 1:
        bodyContent = TeacherHomeworkScreen(onTabRequest: _navigateToTab);
        break;
      case 2:
        bodyContent = const TeacherLessonScreen();
        break;
      case 3:
        bodyContent = const TeacherScheduleScreen();
        break;
      case 4:
        bodyContent = const TeacherProfileScreen();
        break;
      case 5:
        bodyContent = const TeacherHomeworkStatusScreen();
        break;
      case 6:
        bodyContent = const TeacherMyGroupScreen();
        break;
      default:
        bodyContent = const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 0)
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить', onPressed: _refreshDashboard),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              await SessionService.clearSession();
              userProvider.clearUser();
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
                  'Меню преподавателя',
                  style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard_rounded, 'Главная', 0, colors),
            _buildDrawerItem(Icons.assignment_rounded, 'Домашние задания', 1, colors),
            _buildDrawerItem(Icons.checklist_rtl_rounded, 'Проверка ДЗ', 5, colors),
            _buildDrawerItem(Icons.supervised_user_circle_rounded, 'Моя группа', 6, colors),
            ListTile(
              leading: Icon(Icons.message_rounded, color: colors.onSurfaceVariant),
              title: Text('Сообщения', style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.normal)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatListScreen()));
              },
            ),
            _buildDrawerItem(Icons.menu_book_rounded, 'Мои занятия', 2, colors),
            _buildDrawerItem(Icons.calendar_month_rounded, 'Расписание', 3, colors),
            _buildDrawerItem(Icons.person_rounded, 'Профиль', 4, colors),
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
      selectedTileColor: colors.primaryContainer.withOpacity(0.3),
      onTap: () {
        _navigateToTab(index);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildDashboard(ColorScheme colors) {
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
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
            Text(
              'Быстрые действия',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickActionCard(Icons.add_task, 'Выдать ДЗ', () => _navigateToTab(1), colors),
                  _buildQuickActionCard(Icons.checklist, 'Проверить ДЗ', () => _navigateToTab(5), colors),
                  _buildQuickActionCard(Icons.group, 'Моя группа', () => _navigateToTab(6), colors),
                  _buildQuickActionCard(Icons.play_lesson, 'Начать урок', () => _navigateToTab(2), colors),
                  _buildQuickActionCard(Icons.calendar_today, 'Расписание', () => _navigateToTab(3), colors),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Ваши предметы', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
            const SizedBox(height: 12),
            if (_subjects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Предметов пока нет', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subjects.length,
                itemBuilder: (ctx, index) {
                  return _buildSubjectCard(_subjects[index], colors);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject, ColorScheme colors) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToTab(2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colors.secondary, colors.primary]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    subject.name.isNotEmpty ? subject.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      'Нажмите, чтобы перейти к урокам',
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: colors.onSurfaceVariant),
            ],
          ),
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
          Text('С возвращением!', style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Готовы начать учебный день? Проверьте расписание или создайте новые задания.',
            style: TextStyle(color: colors.onPrimary.withOpacity(0.9), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(IconData icon, String label, VoidCallback onTap, ColorScheme colors) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: colors.surface,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: colors.primary, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colors.error),
          const SizedBox(height: 16),
          Text('Не удалось загрузить данные', style: TextStyle(fontSize: 16, color: colors.error)),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh), label: const Text('Повторить')),
        ],
      ),
    );
  }

  Widget _buildTeacherHomeSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 150, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 24),
          const Skeleton(height: 20, width: 150),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder:
                  (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Skeleton(height: 110, width: 110, borderRadius: 16),
                  ),
            ),
          ),
          const SizedBox(height: 24),
          const Skeleton(height: 20, width: 180),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Skeleton(height: 80, width: double.infinity, borderRadius: 16),
            ),
          ),
        ],
      ),
    );
  }
}
