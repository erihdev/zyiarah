import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/core/theme/app_colors.dart';
import 'package:zyiarah/view_model/admin_view_model.dart';
import 'package:zyiarah/view/admin/live_workers_map_screen.dart';

class AdminWorkersScreen extends StatefulWidget {
  const AdminWorkersScreen({super.key});

  @override
  State<AdminWorkersScreen> createState() => _AdminWorkersScreenState();
}

class _AdminWorkersScreenState extends State<AdminWorkersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().fetchAllWorkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموظفين والسائقين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminViewModel>().fetchAllWorkers(),
          ),
        ],
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, adminVM, child) {
          if (adminVM.isLoadingWorkers && adminVM.allWorkers.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (adminVM.errorMessage != null && adminVM.allWorkers.isEmpty) {
            return Center(
              child: Text(adminVM.errorMessage!, style: const TextStyle(color: Colors.red)),
            );
          }

          if (adminVM.allWorkers.isEmpty) {
            return const Center(child: Text('لا يوجد موظفين/سائقين مسجلين في النظام.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: adminVM.allWorkers.length,
            itemBuilder: (context, index) {
              final worker = adminVM.allWorkers[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.person, color: AppColors.primaryDark),
                  ),
                  title: Text(worker.name?.isNotEmpty == true ? worker.name! : 'مندوب غير مسمى', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(worker.phone, textDirection: TextDirection.ltr, textAlign: TextAlign.right),
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: AppColors.primary),
                    tooltip: 'تتبع على الخريطة',
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LiveWorkersMapScreen()),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
