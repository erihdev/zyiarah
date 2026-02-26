import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/booking_model.dart';
import '../services/order_service.dart';

class OrderViewModel extends ChangeNotifier {
  final _orderService = OrderService();
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;

  List<BookingModel> _orders = [];
  List<BookingModel> get orders => _orders;

  List<BookingModel> _adminOrders = [];
  List<BookingModel> get adminOrders => _adminOrders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }

  void _setupRealtime() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    if (_subscription != null) return; // Already setup

    _subscription = _supabase.channel('public:bookings').onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'bookings',
      callback: (payload) {
         // Reload orders when an update happens (like admin approving)
         fetchMyOrders();
      },
    ).subscribe();
  }

  Future<void> fetchMyOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _setupRealtime();
      _orders = await _orderService.fetchUserOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ADMIN METHODS ---
  Future<void> fetchAdminOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _adminOrders = await _orderService.fetchPendingAdminOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changeOrderStatus(String bookingId, String status, {bool isAdmin = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _orderService.updateOrderStatus(bookingId, status);
      
      // Update local lists
      if (isAdmin) {
        _adminOrders.removeWhere((o) => o.id == bookingId);
      } else {
        final index = _orders.indexWhere((o) => o.id == bookingId);
        if (index != -1) {
           // We could manually update, but fetchMyOrders is safer
           await fetchMyOrders(); 
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
