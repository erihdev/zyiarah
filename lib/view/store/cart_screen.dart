import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/view_model/store_view_model.dart';
import 'package:zyiarah/services/promo_service.dart';
import 'package:zyiarah/data/models/promo_code_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoController = TextEditingController();
  final _promoService = PromoService();
  PromoCodeModel? _appliedPromo;
  bool _promoLoading = false;
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromoCode(double cartTotal) async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _promoLoading = true;
      _promoError = null;
      _appliedPromo = null;
    });

    try {
      final promo = await _promoService.validatePromoCode(code, cartTotal);
      if (promo != null) {
        setState(() {
          _appliedPromo = promo;
        });
      }
    } catch (e) {
      setState(() {
        _promoError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _promoLoading = false);
    }
  }

  void _removePromo() {
    setState(() {
      _appliedPromo = null;
      _promoController.clear();
      _promoError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Consumer<StoreViewModel>(
        builder: (context, storeVm, child) {
          if (storeVm.cart.isEmpty) {
            return const Center(
              child: Text(
                'السلة فارغة!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final cartTotal = storeVm.cartTotal;
          double currentDiscount = 0.0;
          if (_appliedPromo != null) {
            if (cartTotal >= _appliedPromo!.minOrderValue) {
              currentDiscount = _promoService.calculateDiscount(_appliedPromo!, cartTotal);
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _removePromo();
              });
            }
          }
          final finalTotal = (cartTotal - currentDiscount).clamp(0.0, double.infinity);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: storeVm.cart.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final cartItem = storeVm.cart[index];
                    return ListTile(
                      leading: cartItem.product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                cartItem.product.imageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image, size: 50),
                      title: Text(cartItem.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${cartItem.product.price} ريال / وحدة'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => storeVm.updateQuantity(cartItem.product, cartItem.quantity - 1),
                          ),
                          Text('${cartItem.quantity}', style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                            onPressed: () => storeVm.updateQuantity(cartItem.product, cartItem.quantity + 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Checkout Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, -2), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promo Code Input
                    if (_appliedPromo == null)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                hintText: 'كود الخصم (مثال: SUMMER20)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                errorText: _promoError,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                            onPressed: _promoLoading ? null : () => _applyPromoCode(cartTotal),
                            child: _promoLoading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('تطبيق'),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_offer, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'كود "${_appliedPromo!.codeName}" - خصم ${currentDiscount.toStringAsFixed(2)} ريال',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _removePromo,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Price Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المجموع الفرعي:'),
                        Text('${cartTotal.toStringAsFixed(2)} ريال'),
                      ],
                    ),
                    if (currentDiscount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الخصم:', style: TextStyle(color: Colors.green)),
                          Text('- ${currentDiscount.toStringAsFixed(2)} ريال', style: const TextStyle(color: Colors.green)),
                        ],
                      ),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الإجمالي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '${finalTotal.toStringAsFixed(2)} ريال',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: storeVm.isLoading
                            ? null
                            : () async {
                                final success = await storeVm.submitOrder(
                                  promoCodeId: _appliedPromo?.id,
                                  discountAmount: currentDiscount,
                                );
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم إرسال طلبك بنجاح!'), backgroundColor: Colors.green),
                                  );
                                  Navigator.pop(context);
                                } else if (context.mounted && storeVm.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('خطأ: ${storeVm.errorMessage}')),
                                  );
                                }
                              },
                        child: storeVm.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'إتمام الطلب (${finalTotal.toStringAsFixed(2)} ريال)',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
