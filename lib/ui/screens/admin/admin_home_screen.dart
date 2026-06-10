import 'package:edu_track/data/services/dashboard_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/screens/admin/academic_periods_screen.dart';
import 'package:edu_track/ui/screens/admin/add_user_screen.dart';
import 'package:edu_track/ui/screens/admin/admin_profile_screen.dart';
import 'package:edu_track/ui/screens/admin/group_admin_screen.dart';
import 'package:edu_track/ui/screens/admin/subject_admin_screen.dart';
import 'package:edu_track/ui/screens/admin/user_list_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/app_drawer.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/ui/widgets/stat_card.dart';
import 'package:edu_track/ui/widgets/welcome_card.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  final List<String> _titles = [
    'Главная',
    'Пользователи',
    'Добавить пользователя',
    'Предметы',
    'Группы',
    'Учебные периоды',
    'Профиль',
  ];
  final DashboardService _dashboardService = DashboardService();
  bool _isLoading = true;
  Map<String, int> _stats = {'students': 0, 'teachers': 0, 'groups': 0, 'subjects': 0};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final instId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (instId == null) return;
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _dashboardService.getStudentCount(instId),
      _dashboardService.getTeacherCount(instId),
      _dashboardService.getGroupCount(instId),
      _dashboardService.getSubjectCount(instId),
    ]);

    if (!mounted) return;

    for (final r in results) {
      if (r.isFailure) {
        MessengerHelper.showError(r.errorMessage);
        setState(() => _isLoading = false);
        return;
      }
    }

    setState(() {
      _stats = {
        'students': results[0].data,
        'teachers': results[1].data,
        'groups': results[2].data,
        'subjects': results[3].data,
      };
      _isLoading = false;
    });
  }

  void _navigateToTab(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _loadDashboardData();
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
        bodyContent = const UserListScreen();
        break;
      case 2:
        bodyContent = AddUserScreen(onUserAdded: () => _navigateToTab(1));
        break;
      case 3:
        bodyContent = const SubjectAdminScreen();
        break;
      case 4:
        bodyContent = const GroupAdminScreen();
        break;
      case 5:
        bodyContent = const AcademicPeriodsScreen();
        break;
      case 6:
        bodyContent = const AdminProfileScreen();
        break;
      default:
        bodyContent = const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        title: Text(
          _selectedIndex < _titles.length ? _titles[_selectedIndex] : '',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 0)
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить данные', onPressed: _loadDashboardData),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Выйти', onPressed: () => _confirmLogout(context)),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton.extended(
                onPressed: () => _navigateToTab(2),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Добавить'),
              )
              : null,
      drawer: AppDrawer(
        title: 'Меню администратора',
        selectedIndex: _selectedIndex,
        onNavigate: _navigateToTab,
        items: const [
          AppDrawerItem(icon: Icons.dashboard_rounded, title: 'Главная', tabIndex: 0),
          AppDrawerItem(icon: Icons.people_alt_rounded, title: 'Пользователи', tabIndex: 1),
          AppDrawerItem(icon: Icons.menu_book_rounded, title: 'Предметы', tabIndex: 3),
          AppDrawerItem(icon: Icons.groups_rounded, title: 'Группы', tabIndex: 4),
          AppDrawerItem(icon: Icons.calendar_month_rounded, title: 'Учебные периоды', tabIndex: 5),
          AppDrawerItem(icon: Icons.person_rounded, title: 'Профиль', tabIndex: 6),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: bodyContent,
      ),
    );
  }

  Widget _buildDashboard(ColorScheme colors) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: colors.primary,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WelcomeCard(
                  title: 'Панель администратора',
                  subtitle: 'Управляйте пользователями, группами и учебным процессом.',
                ),
                const SizedBox(height: 24),
                Text(
                  'Статистика учреждения',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                ),
                const SizedBox(height: AppSpacing.m),
                if (_isLoading)
                  _buildStatsSkeleton()
                else
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      StatCard(
                        title: 'Преподаватели',
                        value: (_stats['teachers'] ?? 0).toString(),
                        icon: Icons.school,
                        iconColor: Colors.orange,
                        compact: true,
                      ),
                      StatCard(
                        title: 'Студенты',
                        value: (_stats['students'] ?? 0).toString(),
                        icon: Icons.people,
                        iconColor: Colors.blue,
                        compact: true,
                      ),
                      StatCard(
                        title: 'Группы',
                        value: (_stats['groups'] ?? 0).toString(),
                        icon: Icons.groups,
                        iconColor: Colors.green,
                        compact: true,
                      ),
                      StatCard(
                        title: 'Предметы',
                        value: (_stats['subjects'] ?? 0).toString(),
                        icon: Icons.menu_book,
                        iconColor: Colors.purple,
                        compact: true,
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
                Text(
                  'Быстрые действия',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                ),
                const SizedBox(height: AppSpacing.l),
                if (_isLoading)
                  _buildQuickActionsSkeleton()
                else
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _quickActionButton('Добавить\nпользователя', Icons.person_add, 2, colors),
                        _quickActionButton('Создать\nгруппу', Icons.group_add, 4, colors),
                        _quickActionButton('Назначить\nпредмет', Icons.book, 3, colors),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSkeleton() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(
        4,
        (_) => const SizedBox(width: 160, height: 88, child: Skeleton(height: 88, width: 160, borderRadius: 16)),
      ),
    );
  }

  Widget _buildQuickActionsSkeleton() {
    return SizedBox(
      height: 110,
      child: Row(
        children: List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Skeleton(height: 110, width: 120, borderRadius: 16),
          ),
        ),
      ),
    );
  }

  Widget _quickActionButton(String label, IconData icon, int pageIndex, ColorScheme colors) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: colors.surface,
        elevation: 2,
        borderRadius: AppRadius.card,
        child: InkWell(
          onTap: () => _navigateToTab(pageIndex),
          borderRadius: AppRadius.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: colors.primary),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
