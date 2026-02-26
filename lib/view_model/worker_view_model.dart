import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/booking_model.dart';
import '../services/order_service.dart';

class WorkerViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _orderService = OrderService();
  RealtimeChannel? _subscription;

  List<BookingModel> _assignedOrders = [];
  List<BookingModel> get assignedOrders => _assignedOrders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
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
