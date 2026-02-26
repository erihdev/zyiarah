import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/view_model/profile_view_model.dart';
import 'package:zyiarah/data/models/address_model.dart';

import 'map_address_picker.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  
  Future<void> _showAddAddressDialog(BuildContext context, ProfileViewModel profileVm) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapAddressPicker()),
    );

    if (result != null && result is Map<String, dynamic> && context.mounted) {
      final double lat = result['lat'];
      final double lng = result['lng'];
      final String addressText = result['address'];

      final success = await profileVm.addAddress(lat, lng, addressText);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الموقع بنجاح')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عناويني'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, profileVm, child) {
          if (profileVm.isLoading && profileVm.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileVm.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'لا يوجد عناوين مسجلة',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة عنوان جديد'),
                    onPressed: () => _showAddAddressDialog(context, profileVm),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profileVm.addresses.length,
            itemBuilder: (context, index) {
              final address = profileVm.addresses[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.location_on, color: Colors.white),
                  ),
                  title: Text(address.fullAddress),
                  subtitle: address.createdAt != null 
                            ? Text('أُضيف في: ${address.createdAt!.toLocal().toString().split(' ')[0]}')
                            : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('حذف العنوان'),
                          content: const Text('هل أنت متأكد أنك تريد حذف هذا العنوان؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                profileVm.deleteAddress(address.id);
                              },
                              child: const Text('حذف', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: context.watch<ProfileViewModel>().addresses.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: () => _showAddAddressDialog(context, context.read<ProfileViewModel>()),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
