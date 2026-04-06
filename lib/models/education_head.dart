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
  final String? avatarUrl;

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
    this.avatarUrl,
  });

  factory EducationHead.fromMap(Map<String, dynamic> map) {
    return EducationHead(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      surname: map['surname']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      login: map['login']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      institutionId: map['institution_id']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
      avatarUrl: map['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'login': login,
      'password': password,
      'institution_id': institutionId,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }

  EducationHead copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? login,
    String? password,
    String? institutionId,
    String? phone,
    DateTime? createdAt,
    String? avatarUrl,
  }) {
    return EducationHead(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      login: login ?? this.login,
      password: password ?? this.password,
      institutionId: institutionId ?? this.institutionId,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
