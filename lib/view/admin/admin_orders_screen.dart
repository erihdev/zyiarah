import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/view_model/order_view_model.dart';
import 'package:zyiarah/data/models/booking_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().fetchAdminOrders();
    });
  }

  void _handleAction(BookingModel order, String newStatus) async {
    final vm = context.read<OrderViewModel>();
    final success = await vm.changeOrderStatus(order.id, newStatus, isAdmin: true);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث حالة الطلب بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحديث الحالة: ${vm.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات (المدير)'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, orderVm, child) {
          if (orderVm.isLoading && orderVm.adminOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderVm.errorMessage != null && orderVm.adminOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('حدث خطأ: ${orderVm.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => orderVm.fetchAdminOrders(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (orderVm.adminOrders.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد طلبات معلقة حالياً.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: orderVm.fetchAdminOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orderVm.adminOrders.length,
              itemBuilder: (context, index) {
                final order = orderVm.adminOrders[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'طلب رقم: ${order.id.substring(0, 8)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${order.totalPrice.toStringAsFixed(2)} ريال',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('معرف المستخدم: ${order.userId}'),
                        if (order.createdAt != null)
                          Text('التاريخ: ${order.createdAt!.toLocal().toString().replaceAll('.000', '')}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              onPressed: () => _handleAction(order, 'rejected'),
                              icon: const Icon(Icons.close),
                              label: const Text('رفض'),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () => _handleAction(order, 'approved_awaiting_payment'),
                              icon: const Icon(Icons.check),
                              label: const Text('موافقة'),
                            ),
                          ],
                        ),
                      ],
                    ),
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
