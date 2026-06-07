import 'package:flutter/material.dart';

class DrawerNavItem extends StatelessWidget {
  const DrawerNavItem({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
      selectedTileColor: colors.primaryContainer.withValues(alpha: 0.3),
      onTap: onTap,
    );
  }
}
