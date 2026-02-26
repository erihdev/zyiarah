class BookingItemModel {
  final String id;
  final String bookingId;
  final String itemName;
  final int quantity;
  final DateTime? createdAt;

  BookingItemModel({
    required this.id,
    required this.bookingId,
    required this.itemName,
    this.quantity = 1,
    this.createdAt,
  });

  factory BookingItemModel.fromMap(Map<String, dynamic> map) {
    return BookingItemModel(
      id: map['id'],
      bookingId: map['booking_id'],
      itemName: map['item_name'],
      quantity: map['quantity'] ?? 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'item_name': itemName,
      'quantity': quantity,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
