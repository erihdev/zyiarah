import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/product_model.dart';
import '../data/models/store_cart_item_model.dart';

class StoreService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);
          
      return (response as List).map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<void> submitStoreOrder(List<StoreCartItemModel> cartItems, double totalPrice, {String? notes, String? promoCodeId, double discountAmount = 0}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      // 1. Create a booking for the store order
      final bookingResponse = await _supabase.from('bookings').insert({
        'user_id': user.id,
        'status': 'pending_admin',
        'total_price': totalPrice,
        'notes': notes,
        if (promoCodeId != null) 'promo_code_id': promoCodeId,
        'discount_amount': discountAmount,
      }).select().single();

      final bookingId = bookingResponse['id'];

      // 2. Insert store_order_items
      final List<Map<String, dynamic>> orderItems = cartItems.map((item) {
        return {
          'booking_id': bookingId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'unit_price': item.product.price,
        };
      }).toList();

      await _supabase.from('store_order_items').insert(orderItems);

    } catch (e) {
      throw Exception('Failed to submit store order: $e');
    }
  }
}
