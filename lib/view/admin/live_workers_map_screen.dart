import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:zyiarah/services/tracking_service.dart';
import 'package:zyiarah/core/theme/app_colors.dart';

class LiveWorkersMapScreen extends StatefulWidget {
  const LiveWorkersMapScreen({super.key});

  @override
  State<LiveWorkersMapScreen> createState() => _LiveWorkersMapScreenState();
}

class _LiveWorkersMapScreenState extends State<LiveWorkersMapScreen> {
  final TrackingService _trackingService = TrackingService();
  
  // Default to Riyadh, KSA as fallback center
  final LatLng _defaultCenter = const LatLng(24.7136, 46.6753);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع السائقين (مباشر)'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _trackingService.getAllWorkersLocationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          
          final List<Map<String, dynamic>> locations = snapshot.data ?? [];
          
          LatLng centerPoint = _defaultCenter;
          if (locations.isNotEmpty) {
            // Center the map on the first driver for simplicity
            centerPoint = LatLng(locations.first['lat'] as double, locations.first['lng'] as double);
          }

          final markers = locations.map((loc) {
            final lat = loc['lat'] as double;
            final lng = loc['lng'] as double;
            final String workerId = (loc['worker_id'] as String).substring(0, 4); // Just for simple ID display

            return Marker(
              point: LatLng(lat, lng),
              width: 60,
              height: 60,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Text(workerId, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  const Icon(Icons.directions_car, color: AppColors.primary, size: 30),
                ],
              ),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: centerPoint,
                  initialZoom: 12.0,
                ),
                children: [
                   TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.zyiarah.app',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              if (locations.isEmpty)
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Text(
                      'لا يوجد سائقين متصلين حالياً على الخريطة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
