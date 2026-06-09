class TimeSlot {
  final String id;
  final String gridId;
  final String? label;
  final String startTime;
  final String endTime;
  final int sortOrder;

  const TimeSlot({
    required this.id,
    required this.gridId,
    this.label,
    required this.startTime,
    required this.endTime,
    required this.sortOrder,
  });

  String get timeRange => '${startTime.substring(0, 5)}–${endTime.substring(0, 5)}';

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id']?.toString() ?? '',
      gridId: map['grid_id']?.toString() ?? '',
      label: map['label']?.toString(),
      startTime: map['start_time']?.toString() ?? '',
      endTime: map['end_time']?.toString() ?? '',
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
