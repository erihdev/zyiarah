import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';
import '../data/models/address_model.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel> fetchUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<void> updateUserProfile(String name) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      await _supabase.from('users').update({'name': name}).eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<List<AddressModel>> fetchUserAddresses() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((e) => AddressModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }

  Future<void> addAddress(double lat, double lng, String fullAddress) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      await _supabase.from('addresses').insert({
        'user_id': user.id,
        'lat': lat,
        'lng': lng,
        'full_address': fullAddress,
      });
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _supabase.from('addresses').delete().eq('id', addressId);
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }
}
