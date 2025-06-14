// Модель для заявки на подключении учреждения
class InstitutionRequest {
  final String id;
  final String name;
  final String city;
  final String email;
  final String status; // например: 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  InstitutionRequest({
    required this.id,
    required this.name,
    required this.city,
    required this.email,
    required this.status,
    required this.createdAt,
  });

  factory InstitutionRequest.fromMap(Map<String, dynamic> map) {
    return InstitutionRequest(
      id: map['id'] as String,
      name: map['name'] as String,
      city: map['city'] as String,
      email: map['email'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'email': email,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
