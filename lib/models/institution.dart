// Модель учреждения
class Institution {
  final String id;
  final String name;
  final String city;
  final DateTime createdAt;

  Institution({
    required this.id,
    required this.name,
    required this.city,
    required this.createdAt,
  });

  factory Institution.fromMap(Map<String, dynamic> map) {
    return Institution(
      id: map['id'] as String,
      name: map['name'] as String,
      city: map['city'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
