import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/booking_model.dart';
import '../services/order_service.dart';

import '../services/tracking_service.dart';

class WorkerViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _orderService = OrderService();
  final _trackingService = TrackingService();
  RealtimeChannel? _subscription;

  List<BookingModel> _assignedOrders = [];
  List<BookingModel> get assignedOrders => _assignedOrders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _subscription?.unsubscribe();
    _trackingService.stopTracking();
    super.dispose();
  }

  Future<void> toggleOnline() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    if (_isOnline) {
      _trackingService.stopTracking();
      _isOnline = false;
      _errorMessage = null;
    } else {
      try {
        await _trackingService.startTracking(user.id);
        _isOnline = true;
        _errorMessage = null;
      } catch (e) {
        _errorMessage = 'فشل تفعيل الموقع: ${e.toString()}';
      }
    }
    notifyListeners();
  }

  Future<void> fetchMyTasks() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('worker_id', user.id)
          .inFilter('status', ['approved_awaiting_payment', 'paid_and_confirmed', 'on_the_way', 'in_progress'])
          .order('created_at', ascending: false);

      _assignedOrders = (response as List).map((e) => BookingModel.fromMap(e)).toList();
      
      // Setup realtime if not done yet
      _setupRealtime(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupRealtime(String workerId) {
    if (_subscription != null) return;

    _subscription = _supabase
        .channel('worker_bookings_$workerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          callback: (payload) => fetchMyTasks(),
        )
        .subscribe();
  }

  Future<bool> updateTaskStatus(String bookingId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(bookingId, newStatus);
      final index = _assignedOrders.indexWhere((o) => o.id == bookingId);
      if (index != -1) {
        await fetchMyTasks();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
