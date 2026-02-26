import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/view_model/order_view_model.dart';
import 'package:zyiarah/view_model/wallet_view_model.dart';
import 'package:zyiarah/data/models/booking_model.dart';
import 'package:zyiarah/core/widgets/luxury_loading_overlay.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel order;

  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'wallet'; // 'wallet', 'card', 'cash'
  bool _isProcessing = false;

  void _handlePayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate payment processing time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final orderVm = context.read<OrderViewModel>();
    final walletVm = context.read<WalletViewModel>();

    bool paymentSuccess = false;

    if (_selectedPaymentMethod == 'wallet') {
      if (walletVm.balance >= widget.order.totalPrice) {
        // Deduct from wallet (assuming we add a deduct method or similar in WalletService)
        // For now, we'll just mock the deduction or rely on admin recharge only in this MVP.
        paymentSuccess = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رصيد المحفظة غير كافٍ. يرجى الشحن أولاً.')),
        );
        setState(() => _isProcessing = false);
        return;
      }
    } else {
      // Card / Cash Mock
      paymentSuccess = true; 
    }

    if (paymentSuccess) {
      final success = await orderVm.changeOrderStatus(widget.order.id, 'paid_and_confirmed');
      if (success && mounted) {
        // Show success, pop twice (back to orders list)
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('تم الدفع بنجاح!', textAlign: TextAlign.center, style: TextStyle(color: Colors.teal)),
            content: const Icon(Icons.check_circle, color: Colors.teal, size: 80),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // close dialog
                  Navigator.pop(context); // close payment screen
                },
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل تحديث الطلب: ${orderVm.errorMessage}')),
          );
        }
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: LuxuryLoadingOverlay(
        isLoading: _isProcessing,
        child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('ملخص الطلب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('رقم الطلب:'),
                              Text(widget.order.id.substring(0, 8), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('المبلغ المطلوب الدفع:', style: TextStyle(fontSize: 16)),
                              Text(
                                '${widget.order.totalPrice.toStringAsFixed(2)} ريال',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Payment Options
                  RadioListTile<String>(
                    title: const Text('المحفظة الإلكترونية'),
                    subtitle: Consumer<WalletViewModel>(
                      builder: (context, vm, _) => Text('الرصيد: ${vm.balance.toStringAsFixed(2)} ريال'),
                    ),
                    value: 'wallet',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                    activeColor: Colors.teal,
                  ),
                  RadioListTile<String>(
                    title: const Text('البطاقة الائتمانية / مدى'),
                    subtitle: const Text('دفع إلكتروني آمن'),
                    value: 'card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                    activeColor: Colors.teal,
                  ),
                  RadioListTile<String>(
                    title: const Text('الدفع عند الاستلام'),
                    value: 'cash',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                    activeColor: Colors.teal,
                  ),

                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _handlePayment,
                    child: Text(
                      'تأكيد الدفع (${widget.order.totalPrice.toStringAsFixed(2)} ريال)',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

