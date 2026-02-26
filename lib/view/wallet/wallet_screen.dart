import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/view_model/wallet_view_model.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // To ensure fresh data when switching tabs:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletViewModel>().fetchWalletData();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('المحفظة الرقمية'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Consumer<WalletViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Text(viewModel.errorMessage!, style: const TextStyle(color: Colors.red)),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.fetchWalletData,
            color: Colors.teal,
            child: Column(
              children: [
                // Balance Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'الرصيد المتاح',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${viewModel.balance.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'سجل العمليات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),

                // Transactions List
                Expanded(
                  child: viewModel.transactions.isEmpty
                      ? const Center(
                          child: Text('لا توجد عمليات سابقة', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: viewModel.transactions.length,
                          itemBuilder: (context, index) {
                            final tx = viewModel.transactions[index];
                            final isPositive = tx.type == 'deposit' || tx.type == 'refund';
                            
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isPositive
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  child: Icon(
                                    isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isPositive ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  tx.description ?? (isPositive ? 'إيداع رصيد' : 'دفع لخدمة'),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  tx.createdAt.toString().split(' ')[0], // Date only
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Text(
                                  '${isPositive ? '+' : '-'} ${tx.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isPositive ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
