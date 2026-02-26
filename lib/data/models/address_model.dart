class AddressModel {
  final String id;
  final String userId;
  final double lat;
  final double lng;
  final String fullAddress;
  final DateTime? createdAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.lat,
    required this.lng,
    required this.fullAddress,
    this.createdAt,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'],
      userId: map['user_id'],
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      fullAddress: map['full_address'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'lat': lat,
      'lng': lng,
      'full_address': fullAddress,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
