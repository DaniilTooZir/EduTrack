import 'package:edu_track/models/group.dart';

// Модель для студента
class Student {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String login;
  final String password;
  final String? groupId;
  final bool isHeadman;
  final DateTime createdAt;
  final Group? group;
  final String? avatarUrl;

  Student({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.login,
    required this.password,
    this.groupId,
    required this.isHeadman,
    required this.createdAt,
    this.group,
    this.avatarUrl,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    final groupMap =
        map['group'] != null ? map['group'] as Map<String, dynamic>? : map['groups'] as Map<String, dynamic>?;
    return Student(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      email: map['email'] ?? '',
      login: map['login'] ?? '',
      password: map['password'] ?? '',
      groupId: map['group_id']?.toString(),
      isHeadman: map['isHeadman'] ?? false,
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
      group: groupMap != null ? Group.fromMap(groupMap) : null,
      avatarUrl: map['avatar_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'login': login,
      'password': password,
      'group_id': groupId,
      'isHeadman': isHeadman,
      'created_at': createdAt.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }
}
