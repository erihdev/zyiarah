import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zyiarah/data/models/booking_model.dart';
import 'package:zyiarah/data/models/user_model.dart';

class AdminViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;

  bool _isLoadingWorkers = false;
  bool get isLoadingWorkers => _isLoadingWorkers;

  List<BookingModel> _allOrders = [];
  List<BookingModel> get allOrders => _allOrders;

  List<UserModel> _allWorkers = [];
  List<UserModel> get allWorkers => _allWorkers;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllOrders() async {
    _isLoadingOrders = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .order('created_at', ascending: false);

      _allOrders = (response as List).map((e) => BookingModel.fromMap(e)).toList();
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء جلب الطلبات: $e';
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllWorkers() async {
    _isLoadingWorkers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('role', 'worker');

      _allWorkers = (response as List).map((e) => UserModel.fromMap(e)).toList();
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء جلب قائمة السائقين: $e';
    } finally {
      _isLoadingWorkers = false;
      notifyListeners();
    }
  }

  Future<bool> assignWorkerToOrder(String orderId, String workerId) async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      await _supabase.from('bookings').update({
        'worker_id': workerId,
        'status': 'paid_and_confirmed', // Moving to active status automatically upon assignment
      }).eq('id', orderId);

      await fetchAllOrders(); // Refresh orders after update
      return true;
    } catch (e) {
      _errorMessage = 'فشل تعيين الطلب: $e';
      _isLoadingOrders = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    _isLoadingOrders = true;
    notifyListeners();
    
    try {
      await _supabase.from('bookings').update({
        'status': newStatus,
      }).eq('id', orderId);

      await fetchAllOrders();
      return true;
    } catch (e) {
       _errorMessage = 'فشل تحديث الحالة: $e';
       _isLoadingOrders = false;
       notifyListeners();
       return false;
    }
  }
}
