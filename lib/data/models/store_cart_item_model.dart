import 'product_model.dart';

class StoreCartItemModel {
  final ProductModel product;
  int quantity;

  StoreCartItemModel({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  // We don't necessarily need toMap/fromMap for DB here, since the DB table is `store_order_items`.
  // But if we want to save cart locally, we might. We'll leave it as a simple state object for now.
}

class StoreOrderItemModel {
  final String id;
  final String bookingId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final DateTime? createdAt;

  StoreOrderItemModel({
    required this.id,
    required this.bookingId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.createdAt,
  });

  factory StoreOrderItemModel.fromMap(Map<String, dynamic> map) {
    return StoreOrderItemModel(
      id: map['id'],
      bookingId: map['booking_id'],
      productId: map['product_id'],
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
