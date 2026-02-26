import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/core/theme/app_colors.dart';
import 'package:zyiarah/view_model/worker_view_model.dart';
import 'package:zyiarah/data/models/booking_model.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerViewModel>().fetchMyTasks();
    });
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'paid_and_confirmed': return 'مؤكد - ينتظر البدء';
      case 'on_the_way': return 'في الطريق';
      case 'in_progress': return 'جاري العمل';
      case 'completed': return 'مكتمل';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid_and_confirmed': return Colors.blue;
      case 'on_the_way': return Colors.orange;
      case 'in_progress': return AppColors.primary;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  String? _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'paid_and_confirmed': return 'on_the_way';
      case 'on_the_way': return 'in_progress';
      case 'in_progress': return 'completed';
      default: return null;
    }
  }

  String? _getNextStatusLabel(String currentStatus) {
    switch (currentStatus) {
      case 'paid_and_confirmed': return 'أنا في الطريق';
      case 'on_the_way': return 'بدء العمل';
      case 'in_progress': return 'إكمال المهمة';
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مهام اليوم'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Consumer<WorkerViewModel>(
            builder: (context, vm, child) {
              return Row(
                children: [
                  Text(vm.isOnline ? 'متصل' : 'غير متصل', style: const TextStyle(fontSize: 12)),
                  Switch(
                    value: vm.isOnline,
                    activeColor: AppColors.accent,
                    inactiveThumbColor: Colors.grey,
                    onChanged: (val) {
                      vm.toggleOnline();
                    },
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WorkerViewModel>().fetchMyTasks(),
          ),
        ],
      ),
      body: Consumer<WorkerViewModel>(
        builder: (context, workerVm, child) {
          if (workerVm.isLoading && workerVm.assignedOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (workerVm.assignedOrders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد مهام اليوم', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: workerVm.fetchMyTasks,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: workerVm.assignedOrders.length,
              itemBuilder: (context, index) {
                final order = workerVm.assignedOrders[index];
                final nextStatus = _getNextStatus(order.status);
                final nextLabel = _getNextStatusLabel(order.status);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                color: _getStatusColor(order.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _translateStatus(order.status),
                                style: TextStyle(color: _getStatusColor(order.status), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        if (order.notes != null && order.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('ملاحظات: ${order.notes}', style: const TextStyle(color: Colors.grey)),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'المبلغ: ${order.totalPrice.toStringAsFixed(2)} ريال',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (nextStatus != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: nextStatus == 'completed' ? Colors.green : AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final success = await workerVm.updateTaskStatus(order.id, nextStatus);
                                if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('فشل التحديث: ${workerVm.errorMessage}')),
                                  );
                                }
                              },
                              icon: Icon(
                                nextStatus == 'completed' ? Icons.check_circle : 
                                nextStatus == 'on_the_way' ? Icons.directions_car : Icons.play_arrow,
                              ),
                              label: Text(nextLabel ?? ''),
                            ),
                          ),
                        ],
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

