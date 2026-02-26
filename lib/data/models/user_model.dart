class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role; // client, admin, worker
  final double walletBalance;
  final String? fcmToken;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.walletBalance = 0.0,
    this.fcmToken,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      role: map['role'] ?? 'client',
      walletBalance: (map['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      fcmToken: map['fcm_token'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'wallet_balance': walletBalance,
      'fcm_token': fcmToken,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
