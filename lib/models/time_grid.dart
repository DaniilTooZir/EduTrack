import 'package:edu_track/models/time_slot.dart';

class TimeGrid {
  final String id;
  final String institutionId;
  final String name;
  final List<TimeSlot> slots;

  const TimeGrid({required this.id, required this.institutionId, required this.name, required this.slots});

  factory TimeGrid.fromMap(Map<String, dynamic> map) {
    final rawSlots = map['time_slots'] as List<dynamic>? ?? [];
    final slots =
        rawSlots.map((s) => TimeSlot.fromMap(s as Map<String, dynamic>)).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return TimeGrid(
      id: map['id']?.toString() ?? '',
      institutionId: map['institution_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slots: slots,
    );
  }
}
