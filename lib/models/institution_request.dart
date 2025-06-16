// Модель для заявки на подключении учреждения
class InstitutionRequest {
  final String id;
  final String name;
  final String address;
  final String headName;
  final String headSurname;
  final String email;
  final String? phone;
  final String? comment;
  final String status;
  final DateTime createdAt;

  InstitutionRequest({
    required this.id,
    required this.name,
    required this.address,
    required this.headName,
    required this.headSurname,
    required this.email,
    this.phone,
    this.comment,
    required this.status,
    required this.createdAt,
  });

  factory InstitutionRequest.fromMap(Map<String, dynamic> map) {
    return InstitutionRequest(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      headName: map['head_name'] as String,
      headSurname: map['head_surname'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      comment: map['comment'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'head_name': headName,
      'head_surname': headSurname,
      'email': email,
      'phone': phone,
      'comment': comment,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}