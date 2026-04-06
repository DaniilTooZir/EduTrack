class ScheduleOperator {
  final String id;
  final String institutionId;
  final String name;
  final String? surname;
  final String? email;
  final String login;
  final String password;
  final DateTime createdAt;

  ScheduleOperator({
    required this.id,
    required this.institutionId,
    required this.name,
    this.surname,
    this.email,
    required this.login,
    required this.password,
    required this.createdAt,
  });

  factory ScheduleOperator.fromMap(Map<String, dynamic> map) {
    return ScheduleOperator(
      id: map['id']?.toString() ?? '',
      institutionId: map['institution_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      surname: map['surname']?.toString(),
      email: map['email']?.toString(),
      login: map['login']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'institution_id': institutionId,
      'name': name,
      'surname': surname,
      'email': email,
      'login': login,
      'password': password,
    };
  }

  ScheduleOperator copyWith({
    String? id,
    String? institutionId,
    String? name,
    String? surname,
    String? email,
    String? login,
    String? password,
    DateTime? createdAt,
  }) {
    return ScheduleOperator(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      login: login ?? this.login,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
