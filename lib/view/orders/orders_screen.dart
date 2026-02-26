import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/view_model/order_view_model.dart';
import 'package:zyiarah/data/models/booking_model.dart';
import 'order_detail_screen.dart';
import 'package:zyiarah/view/payment/payment_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().fetchMyOrders();
    });
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_admin': return Colors.orange;
      case 'approved_awaiting_payment': return Colors.amber;
      case 'paid_and_confirmed': return Colors.teal;
      case 'on_the_way': return Colors.blue;
      case 'in_progress': return Colors.indigo;
      case 'completed': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Usually embedded in BottomNav, but for safety
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, orderVm, child) {
          if (orderVm.isLoading && orderVm.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderVm.errorMessage != null && orderVm.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('حدث خطأ: ${orderVm.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => orderVm.fetchMyOrders(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (orderVm.orders.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد أوامر بعد.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: orderVm.fetchMyOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orderVm.orders.length,
              itemBuilder: (context, index) {
                final order = orderVm.orders[index];
                final isStoreOrder = (order as dynamic).toMap()['type'] == 'store_order' || order.totalPrice > 0; // Simple heuristic since we removed type

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
                      child: Icon(
                        isStoreOrder ? Icons.shopping_bag : Icons.home_repair_service,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                    title: Text(
                      isStoreOrder ? 'طلب أدوات تنظيف' : 'حجز خدمة',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('رقم الطلب: ${order.id.substring(0, 8)}'),
                        if (order.createdAt != null)
                          Text('التاريخ: ${order.createdAt!.toLocal().toString().split(' ')[0]}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _translateStatus(order.status),
                            style: TextStyle(color: _getStatusColor(order.status), fontSize: 12),
                          ),
                        ),
                        if (order.status == 'approved_awaiting_payment') ...[
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentScreen(order: order),
                                ),
                              );
                            },
                            child: const Text('ادفع الآن'),
                          ),
                        ],
                      ],
                    ),
                    trailing: Text(
                      '${order.totalPrice.toStringAsFixed(2)} ريال',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(bookingId: order.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
