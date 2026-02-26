import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/booking_model.dart';
import '../data/models/store_cart_item_model.dart';


class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all bookings for the current user
  Future<List<BookingModel>> fetchUserOrders() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((e) => BookingModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Fetch items for a specific store order
  Future<List<StoreOrderItemModel>> fetchStoreOrderItems(String bookingId) async {
    try {
      final response = await _supabase
          .from('store_order_items')
          .select('*, products(*)') // Join with products table conceptually, but models need mapping
          .eq('booking_id', bookingId);
          
      // Supabase returns nested objects for joins
      return (response as List).map((e) {
        // Map the product object explicitly for the UI if needed, or stick to basic model
        // We'll stick to the basic model to keep it simple, but in a real app, you'd map the joined product too.
        return StoreOrderItemModel.fromMap(e);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch order items: $e');
    }
  }

  // ---- ADMIN & STATUS ACTIONS ----

  // Fetch all pending orders for Admin
  Future<List<BookingModel>> fetchPendingAdminOrders() async {
    try {
      // Assuming Admin has permissions (Row Level Security in Supabase must allow this)
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('status', 'pending_admin')
          .order('created_at', ascending: false);

      return (response as List).map((e) => BookingModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending admin orders: $e');
    }
  }

  // Update order status (used by Admin to approve/reject, or by payment to confirm)
  Future<void> updateOrderStatus(String bookingId, String newStatus) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
