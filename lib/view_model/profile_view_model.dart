import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/models/address_model.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final _profileService = ProfileService();

  UserModel? _user;
  UserModel? get user => _user;

  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfileData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final futures = await Future.wait([
        _profileService.fetchUserProfile(),
        _profileService.fetchUserAddresses(),
      ]);

      _user = futures[0] as UserModel;
      _addresses = futures[1] as List<AddressModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateName(String name) async {
    if (name.trim().isEmpty) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateUserProfile(name.trim());
      // Refresh local user object
      _user = await _profileService.fetchUserProfile();
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

  Future<bool> addAddress(double lat, double lng, String fullAddress) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.addAddress(lat, lng, fullAddress);
      // Refresh addresses
      _addresses = await _profileService.fetchUserAddresses();
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

  Future<bool> deleteAddress(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.deleteAddress(id);
      _addresses.removeWhere((item) => item.id == id);
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
