import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Настройки приложения', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text(
            'Тема оформления',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
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
          const SizedBox(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline, color: theme.colorScheme.outline),
            title: const Text('Версия приложения'),
            trailing: const Text('0.0.4-alpha'),
          ),
          const SizedBox(height: 16),
        ],
      ),
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
            color: selected ? color.withOpacity(0.1) : theme.colorScheme.surface,
            border: Border.all(color: selected ? color : theme.colorScheme.outline.withOpacity(0.3), width: 2),
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

void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const SettingsSheet(),
  );
}
