class BookingModel {
  final String id;
  final String userId;
  final String? addressId;
  final String? workerId;
  final String status; // pending_admin, approved_awaiting_payment, paid_and_confirmed, on_the_way, in_progress, completed, rejected
  final double totalPrice;
  final String? promoCodeId;
  final double discountAmount;
  final String? notes;
  final String? attachmentUrl;
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    this.addressId,
    this.workerId,
    this.status = 'pending_admin',
    required this.totalPrice,
    this.promoCodeId,
    this.discountAmount = 0.0,
    this.notes,
    this.attachmentUrl,
    this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      userId: map['user_id'],
      addressId: map['address_id'],
      workerId: map['worker_id'],
      status: map['status'] ?? 'pending_admin',
      totalPrice: (map['total_price'] as num).toDouble(),
      promoCodeId: map['promo_code_id'],
      discountAmount: (map['discount_amount'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'],
      attachmentUrl: map['attachment_url'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'address_id': addressId,
      'worker_id': workerId,
      'status': status,
      'total_price': totalPrice,
      'promo_code_id': promoCodeId,
      'discount_amount': discountAmount,
      'notes': notes,
      'attachment_url': attachmentUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
