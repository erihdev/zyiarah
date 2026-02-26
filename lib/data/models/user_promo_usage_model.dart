class UserPromoUsageModel {
  final String id;
  final String userId;
  final String promoCodeId;
  final DateTime? usedAt;

  UserPromoUsageModel({
    required this.id,
    required this.userId,
    required this.promoCodeId,
    this.usedAt,
  });

  factory UserPromoUsageModel.fromMap(Map<String, dynamic> map) {
    return UserPromoUsageModel(
      id: map['id'],
      userId: map['user_id'],
      promoCodeId: map['promo_code_id'],
      usedAt: map['used_at'] != null ? DateTime.parse(map['used_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'promo_code_id': promoCodeId,
      'used_at': usedAt?.toIso8601String(),
    };
  }
}
