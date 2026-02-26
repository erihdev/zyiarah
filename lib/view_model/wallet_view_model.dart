import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zyiarah/services/wallet_service.dart';
import 'package:zyiarah/data/models/wallet_transaction_model.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  final String? _userId = Supabase.instance.client.auth.currentUser?.id;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _balance = 0.0;
  double get balance => _balance;

  List<WalletTransactionModel> _transactions = [];
  List<WalletTransactionModel> get transactions => _transactions;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  WalletViewModel() {
    fetchWalletData();
  }

  Future<void> fetchWalletData() async {
    if (_userId == null) return;
    
    _setLoading(true);
    try {
      try {
        _balance = await _walletService.getWalletBalance(_userId!);
      } catch (e) {
         // If a user doesn't exist yet or RLS blocks it, default to 0.0
         print('Could not fetch wallet balance, defaulting to 0.0: $e');
        _balance = 0.0;
      }
      
      try {
        _transactions = await _walletService.getTransactionHistory(_userId!);
      } catch (e) {
         print('Could not fetch transaction history: $e');
        _transactions = [];
      }
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'تعذر تحميل بيانات المحفظة: $e';
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
