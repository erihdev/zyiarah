import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zyiarah/data/models/wallet_transaction_model.dart';
import 'package:zyiarah/data/models/user_model.dart';

class WalletService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<double> getWalletBalance(String userId) async {
    final response = await _supabase
        .from('users')
        .select('wallet_balance')
        .eq('id', userId)
        .maybeSingle();
    
    if (response == null) {
      return 0.0;
    }
    
    return (response['wallet_balance'] ?? 0).toDouble();
  }

  Future<List<WalletTransactionModel>> getTransactionHistory(String userId) async {
    final response = await _supabase
        .from('wallet_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return (response as List).map((e) => WalletTransactionModel.fromMap(e)).toList();
  }

  Future<bool> addTransaction(String userId, double amount, String type, String description) async {
    try {
      // 1. Insert the transaction
      await _supabase.from('wallet_transactions').insert({
        'user_id': userId,
        'amount': amount,
        'type': type,
        'description': description,
      });

      // 2. Update the user's wallet balance
      // Since Supabase RPC (stored procedures) is better for atomic updates, 
      // we'll do a simple select, increment/decrement, and update for this MVP.
      final currentBalance = await getWalletBalance(userId);
      double newBalance = currentBalance;
      
      if (type == 'deposit' || type == 'refund') {
        newBalance += amount;
      } else if (type == 'payment' || type == 'withdrawal') {
        newBalance -= amount;
      }

      await _supabase
          .from('users')
          .update({'wallet_balance': newBalance})
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error in wallet transaction: $e');
      return false;
    }
  }
}
