class AcademicPeriod {
  final String id;
  final String institutionId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  AcademicPeriod({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  bool isCurrent() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  factory AcademicPeriod.fromMap(Map<String, dynamic> map) {
    return AcademicPeriod(
      id: map['id'] as String,
      institutionId: map['institution_id'] as String,
      name: map['name'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institution_id': institutionId,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  AcademicPeriod copyWith({String? id, String? institutionId, String? name, DateTime? startDate, DateTime? endDate}) {
    return AcademicPeriod(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
