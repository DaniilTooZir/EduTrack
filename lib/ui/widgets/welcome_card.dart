import 'package:flutter/material.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.useSecondaryGradient = false,
  });

  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final bool useSecondaryGradient;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              useSecondaryGradient
                  ? [colors.secondary, colors.primary]
                  : [colors.primary.withValues(alpha: 0.8), colors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (subtitleWidget != null)
            subtitleWidget!
          else if (subtitle != null)
            Text(subtitle!, style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.9), fontSize: 14)),
        ],
      ),
    );
  }
}
