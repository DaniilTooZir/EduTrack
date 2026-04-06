import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/subject.dart';

// Модель для домашнего задания
class Homework {
  final String id;
  final String subjectId;
  final String groupId;
  final String? lessonId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final Subject? subject;
  final Group? group;
  final String? fileUrl;
  final String? fileName;

  Homework({
    required this.id,
    required this.subjectId,
    required this.groupId,
    this.lessonId,
    required this.title,
    this.description,
    this.dueDate,
    this.createdAt,
    this.subject,
    this.group,
    this.fileUrl,
    this.fileName,
  });

  factory Homework.fromMap(Map<String, dynamic> map) {
    return Homework(
      id: map['id']?.toString() ?? '',
      subjectId: map['subject_id']?.toString() ?? '',
      groupId: map['group_id']?.toString() ?? '',
      lessonId: map['lesson_id']?.toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      dueDate: map['due_date'] != null ? DateTime.tryParse(map['due_date'].toString()) : null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      subject: map['subject'] != null ? Subject.fromMap(map['subject'] as Map<String, dynamic>) : null,
      group: map['group'] != null ? Group.fromMap(map['group'] as Map<String, dynamic>) : null,
      fileUrl: map['file_url']?.toString(),
      fileName: map['file_name']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'subject_id': subjectId,
      'group_id': groupId,
      if (lessonId != null) 'lesson_id': lessonId,
      'title': title,
      'description': description,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'file_url': fileUrl,
      'file_name': fileName,
    };
  }

  Homework copyWith({
    String? id,
    String? subjectId,
    String? groupId,
    String? lessonId,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? createdAt,
    Subject? subject,
    Group? group,
    String? fileUrl,
    String? fileName,
  }) {
    return Homework(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      groupId: groupId ?? this.groupId,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      subject: subject ?? this.subject,
      group: group ?? this.group,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
    );
  }
}
