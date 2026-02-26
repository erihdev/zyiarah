import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/promo_code_model.dart';

class PromoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<PromoCodeModel?> validatePromoCode(String code, double orderTotal) async {
    try {
      final response = await _supabase
          .from('promo_codes')
          .select()
          .eq('code_name', code.trim().toUpperCase())
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        throw Exception('كود الخصم غير صحيح أو منتهي الصلاحية');
      }

      final promo = PromoCodeModel.fromMap(response);

      // Check expiry
      if (promo.expirationDate != null && promo.expirationDate!.isBefore(DateTime.now())) {
        throw Exception('انتهت صلاحية كود الخصم');
      }

      // Check usage limit
      if (promo.usageLimit != null && promo.currentUsage >= promo.usageLimit!) {
        throw Exception('تم استنفاذ حد استخدام هذا الكود');
      }

      // Check minimum order value
      if (orderTotal < promo.minOrderValue) {
        throw Exception('الحد الأدنى للطلب لاستخدام هذا الكود هو ${promo.minOrderValue.toStringAsFixed(2)} ريال');
      }

      return promo;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل التحقق من الكود: $e');
    }
  }

  double calculateDiscount(PromoCodeModel promo, double orderTotal) {
    double discount = 0;
    if (promo.discountType == 'percentage') {
      discount = orderTotal * (promo.discountValue / 100);
      // Apply max discount cap if set
      if (promo.maxDiscountAmount != null && discount > promo.maxDiscountAmount!) {
        discount = promo.maxDiscountAmount!;
      }
    } else {
      // Fixed discount
      discount = promo.discountValue;
    }
    return discount;
  }
}
