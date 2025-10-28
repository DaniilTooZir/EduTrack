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
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      headName: map['head_name'] ?? '',
      headSurname: map['head_surname'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone']?.toString(),
      comment: map['comment']?.toString(),
      status: map['status'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
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