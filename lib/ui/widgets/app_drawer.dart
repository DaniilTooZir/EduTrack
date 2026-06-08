import 'package:edu_track/ui/widgets/drawer_nav_item.dart';
import 'package:edu_track/ui/widgets/settings_sheet.dart';
import 'package:flutter/material.dart';

class AppDrawerItem {
  final IconData icon;
  final String title;
  final int tabIndex;
  final VoidCallback? customOnTap;

  const AppDrawerItem({required this.icon, required this.title, required this.tabIndex, this.customOnTap});
}

class AppDrawer extends StatelessWidget {
  final String title;
  final int selectedIndex;
  final List<AppDrawerItem> items;
  final void Function(int) onNavigate;

  const AppDrawer({
    super.key,
    required this.title,
    required this.selectedIndex,
    required this.items,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Drawer(
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
              child: Text(title, style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          for (final item in items)
            DrawerNavItem(
              icon: item.icon,
              title: item.title,
              selected: selectedIndex == item.tabIndex,
              onTap:
                  item.customOnTap ??
                  () {
                    onNavigate(item.tabIndex);
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
    );
  }
}
