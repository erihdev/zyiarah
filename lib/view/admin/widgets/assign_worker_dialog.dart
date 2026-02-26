import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/core/theme/app_colors.dart';
import 'package:zyiarah/view_model/admin_view_model.dart';
import 'package:zyiarah/core/widgets/luxury_loading_overlay.dart';

class AssignWorkerDialog extends StatefulWidget {
  final String orderId;

  const AssignWorkerDialog({
    super.key,
    required this.orderId,
  });

  @override
  State<AssignWorkerDialog> createState() => _AssignWorkerDialogState();
}

class _AssignWorkerDialogState extends State<AssignWorkerDialog> {
  String? _selectedWorkerId;
  bool _isAssigning = false;

  void _confirmAssignment() async {
    if (_selectedWorkerId == null) return;

    setState(() => _isAssigning = true);
    
    final success = await context.read<AdminViewModel>().assignWorkerToOrder(
      widget.orderId,
      _selectedWorkerId!,
    );

    setState(() => _isAssigning = false);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعيين السائق بنجاح', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: LuxuryLoadingOverlay(
          isLoading: _isAssigning,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'تعيين مندوب / سائق للطلب',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text('اختر المندوب من القائمة:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<AdminViewModel>(
                  builder: (context, adminVM, child) {
                    if (adminVM.isLoadingWorkers && adminVM.allWorkers.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }

                    if (adminVM.allWorkers.isEmpty) {
                      return const Center(child: Text('لا يوجد مناديب مسجلين بالنظام'));
                    }

                    return ListView.separated(
                      itemCount: adminVM.allWorkers.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final worker = adminVM.allWorkers[index];
                        final isSelected = _selectedWorkerId == worker.id;

                        return ListTile(
                          onTap: () {
                            setState(() => _selectedWorkerId = worker.id);
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          tileColor: isSelected ? AppColors.accent.withOpacity(0.1) : null,
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade300,
                            child: Icon(Icons.person, color: isSelected ? Colors.white : Colors.grey.shade700),
                          ),
                          title: Text(worker.name ?? 'مندوب مفوض', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          subtitle: Text(worker.phone, textDirection: TextDirection.ltr, textAlign: TextAlign.right),
                          trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                            : null,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectedWorkerId == null ? null : _confirmAssignment,
                    child: const Text('تأكيد التعيين'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
