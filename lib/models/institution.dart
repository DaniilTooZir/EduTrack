// Модель учреждения
class Institution {
  final String id;
  final String name;
  final String address;
  final DateTime createdAt;

  Institution({required this.id, required this.name, required this.address, required this.createdAt});

  factory Institution.fromMap(Map<String, dynamic> map) {
    return Institution(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {if (id.isNotEmpty) 'id': id, 'name': name, 'address': address, 'created_at': createdAt.toIso8601String()};
  }

  Institution copyWith({String? id, String? name, String? address, DateTime? createdAt}) {
    return Institution(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
