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
      name: map['name'] ?? '',
      surname: map['surname'] as String?,
      email: map['email'] as String?,
      login: map['login'] ?? '',
      password: map['password'] ?? '',
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'institution_id': institutionId,
      'name': name,
      'surname': surname,
      'email': email,
      'login': login,
      'password': password,
    };
  }
}
