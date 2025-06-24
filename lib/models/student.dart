// Модель для студента
class Student {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String login;
  final String password;
  final String institutionId;
  final String? groupId;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.login,
    required this.password,
    required this.institutionId,
    this.groupId,
    required this.createdAt,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      email: map['email'] as String,
      login: map['login'] as String,
      password: map['password'] as String,
      institutionId: map['institution_id'] as String,
      groupId: map['group_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
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
      'institution_id': institutionId,
      'group_id': groupId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}