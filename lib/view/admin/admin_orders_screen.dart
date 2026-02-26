import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:zyiarah/core/theme/app_colors.dart';
import 'package:zyiarah/view_model/admin_view_model.dart';
import 'package:zyiarah/view/admin/widgets/assign_worker_dialog.dart';
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
      context.read<AdminViewModel>().fetchAllOrders();
      context.read<AdminViewModel>().fetchAllWorkers();
    });
  }

  void _showAssignWorkerDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AssignWorkerDialog(orderId: orderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الطلبات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<AdminViewModel>().fetchAllOrders(),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'الجديدة'),
              Tab(text: 'النشطة'),
              Tab(text: 'المكتملة/الملغاة'),
            ],
          ),
        ),
        body: Consumer<AdminViewModel>(
          builder: (context, adminVM, child) {
            if (adminVM.isLoadingOrders && adminVM.allOrders.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (adminVM.errorMessage != null && adminVM.allOrders.isEmpty) {
              return Center(
                child: Text(adminVM.errorMessage!, style: const TextStyle(color: Colors.red)),
              );
            }

            final pendingOrders = adminVM.allOrders.where((o) => o.status == 'pending_admin' || o.status == 'approved_awaiting_payment').toList();
            final activeOrders = adminVM.allOrders.where((o) => o.status == 'paid_and_confirmed' || o.status == 'on_the_way' || o.status == 'in_progress').toList();
            final historyOrders = adminVM.allOrders.where((o) => o.status == 'completed' || o.status == 'rejected' || o.status == 'cancelled').toList();

            return TabBarView(
              children: [
                _buildOrderList(pendingOrders),
                _buildOrderList(activeOrders),
                _buildOrderList(historyOrders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<BookingModel> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('لا توجد طلبات في هذا القسم'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isAssigned = order.workerId != null && order.workerId!.isNotEmpty;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'طلب #${order.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAssigned ? AppColors.accent.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(order.status),
                        style: TextStyle(
                          color: isAssigned ? AppColors.primary : Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('العميل ID: ${order.userId.substring(0, 8)}', style: const TextStyle(color: Colors.grey)),
                if (order.createdAt != null)
                  Text(
                    'التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt!)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 8),
                Text(
                  'الإجمالي: ${order.totalPrice} ر.س',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isAssigned)
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'المندوب: ${order.workerId!.substring(0, 8)}',
                                style: const TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Text('لم يتم تعيين مندوب', style: TextStyle(color: Colors.orange)),
                    if (order.status != 'completed' && order.status != 'rejected' && order.status != 'cancelled')
                      ElevatedButton.icon(
                        onPressed: () => _showAssignWorkerDialog(order.id),
                        icon: const Icon(Icons.assignment_ind, size: 18),
                        label: Text(isAssigned ? 'تغيير' : 'تعيين'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          backgroundColor: isAssigned ? Colors.grey.shade200 : AppColors.accent,
                          foregroundColor: AppColors.primaryDark,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending_admin':
        return 'جديد - بانتظار الموافقة';
      case 'approved_awaiting_payment':
        return 'بانتظار الدفع';
      case 'paid_and_confirmed':
        return 'مؤكد - بانتظار التنفيذ';
      case 'on_the_way':
        return 'في الطريق';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'rejected':
      case 'cancelled':
        return 'ملغى';
      default:
        return status;
    }
  }
}

