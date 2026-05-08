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
import 'package:edu_track/ui/widgets/settings_sheet.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
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

    final studentResult = await _dashboardService.getStudentCount(instId);
    if (studentResult.isFailure) {
      MessengerHelper.showError(studentResult.errorMessage);
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final teacherResult = await _dashboardService.getTeacherCount(instId);
    if (teacherResult.isFailure) {
      MessengerHelper.showError(teacherResult.errorMessage);
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final groupResult = await _dashboardService.getGroupCount(instId);
    if (groupResult.isFailure) {
      MessengerHelper.showError(groupResult.errorMessage);
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final subjectResult = await _dashboardService.getSubjectCount(instId);
    if (subjectResult.isFailure) {
      MessengerHelper.showError(subjectResult.errorMessage);
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) {
      setState(() {
        _stats = {
          'students': studentResult.data,
          'teachers': teacherResult.data,
          'groups': groupResult.data,
          'subjects': subjectResult.data,
        };
        _isLoading = false;
      });
    }
  }

  void _navigateToTab(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _loadDashboardData();
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
        bodyContent = const UserListScreen();
        break;
      case 2:
        bodyContent = const AddUserScreen();
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
                  'Меню администратора',
                  style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard_rounded, 'Главная', 0, colors),
            _buildDrawerItem(Icons.people_alt_rounded, 'Пользователи', 1, colors),
            _buildDrawerItem(Icons.person_add_alt_1_rounded, 'Добавить пользователя', 2, colors),
            _buildDrawerItem(Icons.menu_book_rounded, 'Предметы', 3, colors),
            _buildDrawerItem(Icons.groups_rounded, 'Группы', 4, colors),
            _buildDrawerItem(Icons.calendar_month_rounded, 'Учебные периоды', 5, colors),
            _buildDrawerItem(Icons.person_rounded, 'Профиль', 6, colors),
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
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
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
    return RefreshIndicator(
      onRefresh: () async {
        await _loadDashboardData();
        await Future.delayed(const Duration(seconds: 1));
      },
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary.withOpacity(0.8), colors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: colors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Панель администратора',
                        style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Управляйте пользователями, группами и учебным процессом.',
                        style: TextStyle(color: colors.onPrimary.withOpacity(0.8), fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Статистика учреждения',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                ),
                const SizedBox(height: 12),
                if (_isLoading)
                  _buildStatsSkeleton()
                else
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _statCard(
                        'Преподаватели',
                        (_stats['teachers'] ?? 0).toString(),
                        Icons.school,
                        Colors.orange,
                        colors,
                      ),
                      _statCard('Студенты', (_stats['students'] ?? 0).toString(), Icons.people, Colors.blue, colors),
                      _statCard('Группы', (_stats['groups'] ?? 0).toString(), Icons.groups, Colors.green, colors),
                      _statCard(
                        'Предметы',
                        (_stats['subjects'] ?? 0).toString(),
                        Icons.menu_book,
                        Colors.purple,
                        colors,
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
                Text(
                  'Быстрые действия',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                ),
                const SizedBox(height: 16),
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToTab(pageIndex),
          borderRadius: BorderRadius.circular(16),
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

  Widget _statCard(String title, String value, IconData icon, Color badgeColor, ColorScheme colors) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: badgeColor, size: 24),
              ),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: badgeColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.onSurface)),
        ],
      ),
    );
  }
}
