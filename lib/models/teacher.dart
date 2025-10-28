// Модель для учителя
class Teacher {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String login;
  final String password;
  final String institutionId;
  final String? department;
  final DateTime createdAt;

  Teacher({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.login,
    required this.password,
    required this.institutionId,
    this.department,
    required this.createdAt,
  });

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      email: map['email'] ?? '',
      login: map['login'] ?? '',
      password: map['password'] ?? '',
      institutionId: map['institution_id']?.toString() ?? '',
      department: map['department'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
      'department': department,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
