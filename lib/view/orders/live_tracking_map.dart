import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:zyiarah/services/tracking_service.dart';

import 'package:zyiarah/core/theme/app_colors.dart';

class LiveTrackingMap extends StatefulWidget {
  final String workerId;
  const LiveTrackingMap({super.key, required this.workerId});

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap> {
  final TrackingService _trackingService = TrackingService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _trackingService.getWorkerLocationStream(widget.workerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('جاري الاتصال بموقع السائق...', style: TextStyle(color: Colors.grey)),
          );
        }

        final data = snapshot.data!.first;
        final lat = data['lat'] as double;
        final lng = data['lng'] as double;
        final position = LatLng(lat, lng);

        return FlutterMap(
          options: MapOptions(
            initialCenter: position,
            initialZoom: 16.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.zyiarah.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: position,
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                      ]
                    ),
                    child: const Icon(Icons.directions_car, color: AppColors.primary, size: 30),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
