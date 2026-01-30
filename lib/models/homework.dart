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
      title: map['title'] ?? '',
      description: map['description'],
      dueDate: map['due_date'] != null ? DateTime.tryParse(map['due_date'].toString()) : null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      subject: map['subject'] != null ? Subject.fromMap(map['subject'] as Map<String, dynamic>) : null,
      group: map['group'] != null ? Group.fromMap(map['group'] as Map<String, dynamic>) : null,
      fileUrl: map['file_url'],
      fileName: map['file_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
}
