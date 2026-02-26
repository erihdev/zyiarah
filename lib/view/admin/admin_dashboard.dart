import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zyiarah/core/theme/app_colors.dart';
import 'package:zyiarah/view/admin/live_workers_map_screen.dart';
import 'package:zyiarah/view/admin/admin_orders_screen.dart';
import 'package:zyiarah/view/admin/admin_workers_screen.dart';
import 'package:zyiarah/view/auth/auth_gate_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGateScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مرحباً أستاذي،', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('لوحة الإدارة الشاملة (Web/Mobile)', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              const Text('العمليات الأساسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),

              // Grid of Admin Tasks
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                   _buildAdminCard(
                    context, 
                    title: 'إدارة الطلبات', 
                    icon: Icons.list_alt, 
                    color: Colors.blue.shade600,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen()));
                    }
                  ),
                  _buildAdminCard(
                    context, 
                    title: 'الموظفين والسائقين', 
                    icon: Icons.people_alt, 
                    color: Colors.orange.shade700,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWorkersScreen()));
                    }
                  ),
                  _buildAdminCard(
                    context, 
                    title: 'تتبع السائقين (مباشر)', 
                    icon: Icons.map, 
                    color: Colors.red.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LiveWorkersMapScreen()),
                      );
                    }
                  ),
                   _buildAdminCard(
                    context, 
                    title: 'المالية (السحب والأرباح)\nقريباً', 
                    icon: Icons.account_balance_wallet, 
                    color: Colors.grey.shade400,
                    onTap: () {}
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {
    required String title, 
    required IconData icon, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title, 
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
