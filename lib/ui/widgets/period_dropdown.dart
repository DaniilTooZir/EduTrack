import 'package:edu_track/models/academic_period.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeriodDropdown extends StatelessWidget {
  const PeriodDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        final periods = provider.periods;
        final selected = provider.selectedPeriod;
        if (periods.isEmpty) return const SizedBox.shrink();

        return PopupMenuButton<AcademicPeriod>(
          tooltip: 'Учебный период',
          offset: const Offset(0, 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.date_range, size: 18),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 90),
                  child: Text(
                    selected?.name ?? '—',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
          onSelected: (period) {
            Provider.of<UserProvider>(context, listen: false).setSelectedPeriod(period);
          },
          itemBuilder: (context) => periods.map((period) {
            final isSelected = selected?.id == period.id;
            final isCurrent = period.isCurrent();
            return PopupMenuItem<AcademicPeriod>(
              value: period,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: isSelected ? const Icon(Icons.check, size: 18) : null,
                  ),
                  Expanded(child: Text(period.name)),
                  if (isCurrent)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('сейчас', style: TextStyle(fontSize: 10, color: Colors.green)),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
