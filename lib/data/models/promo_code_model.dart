class PromoCodeModel {
  final String id;
  final String codeName;
  final String discountType; // percentage, fixed
  final double discountValue;
  final double? maxDiscountAmount;
  final double minOrderValue;
  final DateTime? expirationDate;
  final int? usageLimit;
  final int currentUsage;
  final bool isActive;
  final DateTime? createdAt;

  PromoCodeModel({
    required this.id,
    required this.codeName,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    this.minOrderValue = 0.0,
    this.expirationDate,
    this.usageLimit,
    this.currentUsage = 0,
    this.isActive = true,
    this.createdAt,
  });

  factory PromoCodeModel.fromMap(Map<String, dynamic> map) {
    return PromoCodeModel(
      id: map['id'],
      codeName: map['code_name'],
      discountType: map['discount_type'],
      discountValue: (map['discount_value'] as num).toDouble(),
      maxDiscountAmount: (map['max_discount_amount'] as num?)?.toDouble(),
      minOrderValue: (map['min_order_value'] as num?)?.toDouble() ?? 0.0,
      expirationDate: map['expiration_date'] != null ? DateTime.parse(map['expiration_date']) : null,
      usageLimit: map['usage_limit'],
      currentUsage: map['current_usage'] ?? 0,
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code_name': codeName,
      'discount_type': discountType,
      'discount_value': discountValue,
      'max_discount_amount': maxDiscountAmount,
      'min_order_value': minOrderValue,
      'expiration_date': expirationDate?.toIso8601String(),
      'usage_limit': usageLimit,
      'current_usage': currentUsage,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
