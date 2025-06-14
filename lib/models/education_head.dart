// Модель для руководителя учреждением(админа)
class EducationHead {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String password;
  final String institutionId;
  final DateTime createdAt;

  EducationHead({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.password,
    required this.institutionId,
    required this.createdAt,
  });

  factory EducationHead.fromMap(Map<String, dynamic> map) {
    return EducationHead(
      id: map['id'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      institutionId: map['institution_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'institution_id': institutionId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

