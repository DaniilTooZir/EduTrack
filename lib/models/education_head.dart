// Модель для руководителя учреждением(админа)
class EducationHead {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String login;
  final String password;
  final String institutionId;
  final String phone;
  final DateTime createdAt;

  EducationHead({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.login,
    required this.password,
    required this.institutionId,
    required this.phone,
    required this.createdAt,
  });

  factory EducationHead.fromMap(Map<String, dynamic> map) {
    return EducationHead(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      email: map['email'] ?? '',
      login: map['login'] ?? '',
      password: map['password'] ?? '',
      institutionId: map['institution_id']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
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
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

