import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zyiarah/core/theme/app_colors.dart';

class MapAddressPicker extends StatefulWidget {
  const MapAddressPicker({super.key});

  @override
  State<MapAddressPicker> createState() => _MapAddressPickerState();
}

class _MapAddressPickerState extends State<MapAddressPicker> {
  final MapController _mapController = MapController();
  
  // Default to Riyadh, Saudi Arabia
  LatLng _centerPosition = const LatLng(24.7136, 46.6753);
  bool _isLoadingAddress = false;
  String _currentAddress = 'جاري تحديد الموقع...';

  @override
  void initState() {
    super.initState();
    _getAddressFromLatLng(_centerPosition);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
      _currentAddress = 'جاري تحديد الموقع...';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        List<String> addressParts = [];
        if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
        if (place.street != null && place.street!.isNotEmpty) addressParts.add(place.street!);
        
        setState(() {
          if (addressParts.isEmpty) {
            _currentAddress = 'موقع غير معروف بالتحديد';
          } else {
            // Filter out unnamed roads and duplicates simply
            _currentAddress = addressParts.where((part) => part.isNotEmpty && part != 'Unnamed Road').join('، ');
            if (_currentAddress.isEmpty) _currentAddress = 'موقع محدد على الخريطة';
          }
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _currentAddress = 'تعذر استرجاع اسم الموقع';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'تم تحديد الموقع بالإحداثيات';
        _isLoadingAddress = false;
      });
    }
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _centerPosition = camera.center;
    // Debounce would be better here for production, but calling directly for simplicity
    // Or we can just call it only when the map stops moving.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حدد موقعك'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerPosition,
              initialZoom: 14.0,
              onPositionChanged: _onPositionChanged,
              onMapEvent: (MapEvent event) {
                if (event is MapEventMoveEnd) {
                  _getAddressFromLatLng(_centerPosition);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.zyiarah.app',
              ),
            ],
          ),
          
          // Center Marker (Static in UI, map moves underneath)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0), // Adjust to point tip at center
              child: Icon(
                Icons.location_on,
                size: 50,
                color: AppColors.accent,
              ),
            ),
          ),

          // Bottom Info Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_city, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _currentAddress,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isLoadingAddress)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoadingAddress 
                      ? null 
                      : () {
                          // Return result back to calling screen
                          Navigator.pop(context, {
                            'lat': _centerPosition.latitude,
                            'lng': _centerPosition.longitude,
                            'address': _currentAddress,
                          });
                        },
                    child: const Text('تأكيد الموقع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
