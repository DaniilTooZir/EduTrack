// Модель для учеников
class Student {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String password;
  final String institutionId;
  final int classNumber;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.password,
    required this.institutionId,
    required this.classNumber,
    required this.createdAt,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      institutionId: map['institution_id'] as String,
      classNumber: map['class_number'] as int,
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
      'class_number': classNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
