// Модель учреждения
class Institution {
  final String id;
  final String name;
  final String address;
  final DateTime createdAt;

  Institution({
    required this.id,
    required this.name,
    required this.address,
    required this.createdAt,
  });

  factory Institution.fromMap(Map<String, dynamic> map) {
    return Institution(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
