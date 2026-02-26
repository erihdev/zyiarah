import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyContractsScreen extends StatefulWidget {
  const MyContractsScreen({super.key});

  @override
  State<MyContractsScreen> createState() => _MyContractsScreenState();
}

class _MyContractsScreenState extends State<MyContractsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _contracts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .eq('client_id', user.id)
          .order('signed_at', ascending: false);

      setState(() {
        _contracts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عقودي'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contracts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا توجد عقود سارية', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadContracts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _contracts.length,
                    itemBuilder: (context, index) {
                      final contract = _contracts[index];
                      final status = contract['status'] ?? 'active';
                      final serviceType = contract['service_type'] ?? 'خدمة';
                      final signedAt = contract['signed_at'] != null
                          ? DateTime.parse(contract['signed_at']).toLocal().toString().split('.')[0]
                          : '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: status == 'active' ? Colors.green.shade100 : Colors.grey.shade100,
                            child: Icon(
                              Icons.article,
                              color: status == 'active' ? Colors.green : Colors.grey,
                            ),
                          ),
                          title: Text(serviceType, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('تاريخ التوقيع: $signedAt'),
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: status == 'active' ? Colors.green.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status == 'active' ? 'ساري' : 'منتهي',
                                  style: TextStyle(color: status == 'active' ? Colors.green : Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
