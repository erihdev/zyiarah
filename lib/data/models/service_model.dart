class ServiceModel {
  final String id;
  final String name;
  final String type; // hourly, monthly, maintenance
  final double basePrice;
  final DateTime? createdAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.basePrice,
    this.createdAt,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      basePrice: (map['base_price'] as num).toDouble(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'base_price': basePrice,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
