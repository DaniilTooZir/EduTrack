import 'package:edu_track/data/services/notification_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _notificationsEnabled = prefs.getBool(kNotificationsKey) ?? true);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotificationsKey, value);
    if (!value) {
      await NotificationService().cancelAllScheduled();
    }
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
    if (confirmed != true) return;
    if (!context.mounted) return;
    await Provider.of<UserProvider>(context, listen: false).clearUser();
    if (context.mounted) context.go(AppRoutes.welcome);
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'EduTrack',
      applicationVersion: '0.0.5-alpha',
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const SizedBox(height: 8),
        const Text('Система управления учебным процессом для преподавателей, студентов и администраторов.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final colors = Theme.of(context).colorScheme;
    final isLoggedIn = userProvider.userId != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(label: 'Тема оформления'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _ThemeCard(
                  label: 'Светлая',
                  icon: Icons.wb_sunny_rounded,
                  selected: themeProvider.mode == AppThemeMode.light,
                  color: Colors.orange,
                  onTap: () => themeProvider.setTheme(AppThemeMode.light),
                ),
                const SizedBox(width: 12),
                _ThemeCard(
                  label: 'Темная',
                  icon: Icons.nightlight_round,
                  selected: themeProvider.mode == AppThemeMode.dark,
                  color: Colors.blueGrey,
                  onTap: () => themeProvider.setTheme(AppThemeMode.dark),
                ),
                const SizedBox(width: 12),
                _ThemeCard(
                  label: 'Фиолетовая',
                  icon: Icons.palette_rounded,
                  selected: themeProvider.mode == AppThemeMode.purple,
                  color: const Color(0xFF5E35B1),
                  onTap: () => themeProvider.setTheme(AppThemeMode.purple),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _SectionHeader(label: 'Уведомления'),
          SwitchListTile(
            secondary: Icon(
              _notificationsEnabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
              color: _notificationsEnabled ? colors.primary : colors.outline,
            ),
            title: const Text('Уведомления'),
            subtitle: const Text('Напоминания о дедлайнах и событиях'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          const SizedBox(height: 8),
          _SectionHeader(label: 'О приложении'),
          ListTile(
            leading: Icon(Icons.info_outline, color: colors.outline),
            title: const Text('EduTrack'),
            subtitle: const Text('Версия 0.0.5-alpha'),
            onTap: () => _showAboutDialog(context),
            trailing: Icon(Icons.chevron_right, color: colors.outline),
          ),
          const SizedBox(height: 8),
          if (isLoggedIn) ...[
            _SectionHeader(label: 'Аккаунт'),
            ListTile(
              leading: Icon(Icons.logout, color: colors.error),
              title: Text('Выйти из аккаунта', style: TextStyle(color: colors.error)),
              onTap: () => _confirmLogout(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.8)),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _ThemeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : theme.colorScheme.surface,
            border: Border.all(color: selected ? color : theme.colorScheme.outline.withValues(alpha: 0.3), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : theme.colorScheme.onSurface),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : theme.colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
