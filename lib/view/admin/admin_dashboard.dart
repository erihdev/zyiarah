import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/view_model/auth_view_model.dart';
import 'package:zyiarah/core/theme/app_colors.dart';
import 'live_workers_map_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Reset auth correctly
              context.read<AuthViewModel>().resetAuth();
              Navigator.pushReplacementNamed(context, '/roles');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminActionCard(
            context,
            title: 'تتبع السائقين (مباشر)',
            icon: Icons.map,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveWorkersMapScreen()),
              );
            },
          ),
          
          _buildAdminActionCard(
            context,
            title: 'مراجعة الطلبات المعلقة',
            icon: Icons.pending_actions,
            color: AppColors.accentDark,
            onTap: () {
              // Build orders screen later if needed 
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم تفعيلها قريباً')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

