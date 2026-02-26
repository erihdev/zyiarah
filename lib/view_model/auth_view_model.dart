import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isOtpSent = false;
  bool get isOtpSent => _isOtpSent;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _phoneNumber = '';

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    // Simple validation (can be expanded based on local phone format)
    if (!_phoneNumber.startsWith('+')) {
       _phoneNumber = '+966' + (_phoneNumber.startsWith('0') ? _phoneNumber.substring(1) : _phoneNumber);
    }
  }

  Future<void> sendOtp() async {
    if (_phoneNumber.isEmpty) {
      _errorMessage = 'الرجاء إدخال رقم الجوال';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _supabase.auth.signInWithOtp(
        phone: _phoneNumber,
      );
      _isOtpSent = true;
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = _translateAuthError(e.message);
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
    }
    _setLoading(false);
  }

  Future<bool> verifyOtp(String otp) async {
    if (otp.isEmpty || otp.length < 6) {
      _errorMessage = 'الرجاء إدخال رمز التحقق كاملاً';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: _phoneNumber,
      );
      
      _setLoading(false);
      if (response.session != null) {
        final userId = response.session!.user.id;
        final userPhone = response.session!.user.phone ?? _phoneNumber;
        
        // Ensure user exists in our public.users table
        try {
          await _supabase.from('users').upsert({
            'id': userId,
            'phone': userPhone,
            'name': 'مستخدم جديد', // Default name
          });
        } catch (e) {
          debugPrint('Error upserting user: $e');
        }

        return true; // Success
      } else {
        _errorMessage = 'تعذر تسجيل الدخول، حاول مرة أخرى';
        return false;
      }
    } on AuthException catch (e) {
      _setLoading(false);
      _errorMessage = _translateAuthError(e.message);
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'حدث خطأ أثناء التحقق: $e';
      return false;
    }
  }

  void resetAuth() {
    _isOtpSent = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _translateAuthError(String error) {
    if (error.contains('rate limit')) return 'حاولت مرات كثيرة، الرجاء الانتظار لفترة.';
    if (error.contains('invalid format')) return 'صيغة رقم الجوال غير صحيحة.';
    if (error.contains('expired')) return 'انتهت صلاحية الرمز، استرد رمزاً جديداً.';
    if (error.contains('invalid claim') || error.contains('invalid token')) return 'رمز التحقق غير صحيح.';
    return 'خطأ في المصادقة: $error';
  }
}
