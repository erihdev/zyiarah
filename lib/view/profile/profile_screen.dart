import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/profile_view_model.dart';
import 'address_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfileData();
    });
  }

  void _showEditNameDialog(BuildContext context, ProfileViewModel profileVm) {
    final TextEditingController nameController = TextEditingController(text: profileVm.user?.name ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل الاسم'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'الاسم الجديد',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context);
                  final success = await profileVm.updateName(newName);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث الاسم بنجاح')),
                    );
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevents back button on main bottom nav
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, profileVm, child) {
          if (profileVm.isLoading && profileVm.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileVm.errorMessage != null && profileVm.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('حدث خطأ: ${profileVm.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => profileVm.loadProfileData(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final user = profileVm.user;
          if (user == null) return const Center(child: Text('لا توجد بيانات مستخدم'));

          return RefreshIndicator(
            onRefresh: profileVm.loadProfileData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Header
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name Row with Edit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name.isEmpty ? 'مستخدم جديد' : user.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.teal, size: 20),
                        onPressed: () => _showEditNameDialog(context, profileVm),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    user.phone,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 32),

                  // Option Tiles
                  _buildOptionTile(
                    icon: Icons.location_on_outlined,
                    title: 'عناويني',
                    subtitle: 'إدارة مواقع التوصيل والخدمة',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddressScreen()),
                      );
                    },
                  ),
                  
                  _buildOptionTile(
                    icon: Icons.language_outlined,
                    title: 'اللغة',
                    subtitle: 'العربية',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('النسخة الحالية تدعم العربية فقط')),
                      );
                    },
                  ),

                  _buildOptionTile(
                    icon: Icons.help_outline,
                    title: 'المساعدة والدعم',
                    subtitle: 'تواصل معنا لحل مشكلتك',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('سيتم تفعيل الدعم قريباً')),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  const Text('الإصدار 1.0.0', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
