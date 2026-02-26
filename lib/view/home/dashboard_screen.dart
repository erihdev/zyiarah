import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:zyiarah/view/store/store_screen.dart';
import 'package:zyiarah/services/marketing_service.dart';
import 'package:zyiarah/core/widgets/animated_brand_logo.dart';
import 'package:zyiarah/view/contracts/my_contracts_screen.dart';
import 'package:zyiarah/core/widgets/fade_page_route.dart';
import 'package:zyiarah/view/bookings/resident_hiring_flow.dart';
import 'package:zyiarah/view/store/subscription_packages_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _marketingService = MarketingService();

  @override
  void initState() {
    super.initState();
    _checkForCampaigns();
  }

  Future<void> _checkForCampaigns() async {
    final campaign = await _marketingService.fetchUnseenCampaign();
    if (campaign != null && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(campaign['title'] ?? 'عرض خاص', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (campaign['image_url'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(campaign['image_url'], errorBuilder: (ctx, _, __) => const SizedBox()),
                ),
              if (campaign['description'] != null) ...[
                const SizedBox(height: 12),
                Text(campaign['description'], textAlign: TextAlign.center),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق', style: TextStyle(color: Colors.teal)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // قائمة الخدمات المتاحة فقط
    final List<Map<String, dynamic>> services = [
      {'title': 'زيارة بالساعة', 'icon': Icons.hourglass_bottom, 'color': Colors.blue},
      {'title': 'عاملة مقيمة', 'icon': Icons.home, 'color': Colors.pink},
      {'title': 'غسيل مكيفات', 'icon': Icons.ac_unit, 'color': Colors.teal},
      {'title': 'المتجر', 'icon': Icons.store, 'color': Colors.purple},
    ];

    // قائمة تجريبية للبانرات الإعلانية
    final List<String> imgList = [
      'https://images.unsplash.com/photo-1581094794329-c8112a89af12?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1595846519845-68e298c2ef80?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const AnimatedBrandLogo(size: 40),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.description_outlined, color: Colors.teal),
          onPressed: () => Navigator.push(context, FadePageRoute(page: const MyContractsScreen())),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // ... (I'll just replace the whole body section for safety)
            CarouselSlider(
              options: CarouselOptions(
                height: 180.0,
                autoPlay: true,
                enlargeCenterPage: true,
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.85,
              ),
              items: imgList.map((item) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)],
                  image: DecorationImage(image: NetworkImage(item), fit: BoxFit.cover),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: LinearGradient(
                      colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'خصم 20% على خدمات التنظيف!',
                        style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),

            const SizedBox(height: 30),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text('الخدمات المتاحة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.2,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return InkWell(
                    onTap: () {
                    if (service['title'] == 'المتجر') {
                      Navigator.push(context, FadePageRoute(page: const StoreScreen()));
                    } else if (service['title'] == 'عاملة مقيمة') {
                      Navigator.push(context, FadePageRoute(page: const ResidentHiringFlow()));
                    } else if (service['title'] == 'زيارة بالساعة') {
                      Navigator.push(context, FadePageRoute(page: const SubscriptionPackagesScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('سيتم تفعيل خدمة "${service['title']}" قريباً')),
                      );
                    }
                  },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withValues(alpha: 0.15), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3)),
                        ],
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: service['color'].withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(service['icon'], color: service['color'], size: 32),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            service['title'],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
