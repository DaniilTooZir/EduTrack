class FinalGrade {
  final String? id;
  final String studentId;
  final String subjectId;
  final String groupId;
  final String periodId;
  final int value;
  final bool isManual;
  final String? teacherId;

  FinalGrade({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.groupId,
    required this.periodId,
    required this.value,
    required this.isManual,
    this.teacherId,
  });

  factory FinalGrade.fromMap(Map<String, dynamic> map) {
    return FinalGrade(
      id: map['id']?.toString(),
      studentId: map['student_id']?.toString() ?? '',
      subjectId: map['subject_id']?.toString() ?? '',
      groupId: map['group_id']?.toString() ?? '',
      periodId: map['period_id']?.toString() ?? '',
      value: int.tryParse(map['value'].toString()) ?? 0,
      isManual: map['is_manual'] as bool? ?? true,
      teacherId: map['teacher_id']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
      'group_id': groupId,
      'period_id': periodId,
      'value': value,
      'is_manual': isManual,
      if (teacherId != null) 'teacher_id': teacherId,
    };
  }

  FinalGrade copyWith({
    String? id,
    String? studentId,
    String? subjectId,
    String? groupId,
    String? periodId,
    int? value,
    bool? isManual,
    String? teacherId,
  }) {
    return FinalGrade(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      groupId: groupId ?? this.groupId,
      periodId: periodId ?? this.periodId,
      value: value ?? this.value,
      isManual: isManual ?? this.isManual,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}
