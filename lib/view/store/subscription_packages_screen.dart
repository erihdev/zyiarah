import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:zyiarah/view/contracts/contract_screen.dart';

class SubscriptionPackagesScreen extends StatelessWidget {
  const SubscriptionPackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> hourlyPackages = [
      {
        'title': 'باقة الزيارة الواحدة',
        'visits': 'زيارة واحدة',
        'price': 120,
        'features': ['تنظيف شامل (4 ساعات)', 'عاملة واحدة', 'توصيل مجاني'],
        'color': Colors.blue.shade700,
      },
      {
        'title': 'باقة التوفير (شهري)',
        'visits': '4 زيارات شهرياً',
        'price': 420,
        'features': ['زيارة كل أسبوع', 'نفس العاملة (حسب الطلب)', 'خصم 15%', 'أولوية الحجز'],
        'color': Colors.teal.shade700,
      },
      {
        'title': 'الباقة القصوى (شهري)',
        'visits': '8 زيارات شهرياً',
        'price': 780,
        'features': ['زيارتين كل أسبوع', 'نفس العاملة دائماً', 'خصم 25%', 'دعم فني مخصص'],
        'color': Colors.purple.shade700,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('باقات الاشتراكات بالساعة'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: hourlyPackages.length,
        itemBuilder: (context, index) {
          final pkg = hourlyPackages[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [pkg['color'], pkg['color'].withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: pkg['color'].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(pkg['title'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                        child: Text(pkg['visits'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('SAR', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(width: 4),
                      Text('${pkg['price']}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.white30, height: 30),
                  ... (pkg['features'] as List<String>).map((feat) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(feat, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ContractScreen(
                            bookingId: const Uuid().v4(),
                            serviceType: 'اشتراك ساعة - ${pkg['title']} (${pkg['visits']})',
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: pkg['color'],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('اشترك الآن', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
