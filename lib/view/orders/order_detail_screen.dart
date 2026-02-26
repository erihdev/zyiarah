import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/services/order_service.dart';
import 'package:zyiarah/data/models/store_cart_item_model.dart';
import 'package:zyiarah/data/models/booking_model.dart';
import 'package:zyiarah/view_model/order_view_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String bookingId;

  const OrderDetailScreen({super.key, required this.bookingId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  List<StoreOrderItemModel> _items = [];
  String? _errorMessage;
  BookingModel? _order;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      // Find the order from the provider (since it was just listed there)
      final orderVm = context.read<OrderViewModel>();
      _order = orderVm.orders.firstWhere((o) => o.id == widget.bookingId);

      // Fetch items (if it's a store order)
      _items = await _orderService.fetchStoreOrderItems(widget.bookingId);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'pending_admin': return 'بانتظار المراجعة';
      case 'approved_awaiting_payment': return 'بانتظار الدفع';
      case 'paid_and_confirmed': return 'مؤكد المدفوع';
      case 'on_the_way': return 'في الطريق';
      case 'in_progress': return 'قيد التنفيذ';
      case 'completed': return 'مكتمل';
      case 'rejected': return 'مرفوض';
      default: return 'حالة غير معروفة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('حدث خطأ: $_errorMessage'))
              : _buildOrderDetails(),
    );
  }

  Widget _buildOrderDetails() {
    if (_order == null) return const Center(child: Text('الطلب غير موجود'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('رقم الطلب:', style: TextStyle(color: Colors.grey)),
                      Text(_order!.id.substring(0, 8), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('تاريخ الطلب:', style: TextStyle(color: Colors.grey)),
                      Text('${_order!.createdAt?.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('حالة الطلب:', style: TextStyle(color: Colors.grey)),
                      Text(_translateStatus(_order!.status), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('المنتجات / الخدمات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (_items.isEmpty)
             const Padding(
               padding: EdgeInsets.all(16.0),
               child: Text('هذا الطلب عبارة عن خدمة مجدولة أو لا يحتوي على تفاصيل عناصر.'),
             )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text('منتج معرف: ${item.productId.substring(0,6)}'), // In real app, we'd join and get name
                  subtitle: Text('الكمية: ${item.quantity}'),
                  trailing: Text('${(item.unitPrice * item.quantity).toStringAsFixed(2)} ريال'),
                );
              },
            ),

          const SizedBox(height: 24),
          
          if (_order!.notes != null && _order!.notes!.isNotEmpty) ...[
            const Text('ملاحظات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_order!.notes!),
            ),
            const SizedBox(height: 24),
          ],

          // Footer Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي الكلي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  '${_order!.totalPrice.toStringAsFixed(2)} ريال',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
