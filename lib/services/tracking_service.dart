import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class TrackingService {
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<Position>? _positionStream;

  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return false;
    } 

    if (permission == LocationPermission.whileInUse) {
      // Optionally request always if we need reliable background tracking
      // We will try using permission_handler for background
      var bgStatus = await Permission.locationAlways.request();
      if (!bgStatus.isGranted) {
        debugPrint('Always location permission not granted. Will try to work with while-in-use.');
      }
    }

    return true;
  }

  Future<void> startTracking(String workerId) async {
    if (_positionStream != null) return; // Already tracking

    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      throw Exception('Location permissions are denied');
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      _updateLocationInDb(workerId, position.latitude, position.longitude);
    });
  }

  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<void> _updateLocationInDb(String workerId, double lat, double lng) async {
    try {
      await _supabase.from('worker_locations').upsert({
        'worker_id': workerId,
        'lat': lat,
        'lng': lng,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getWorkerLocationStream(String workerId) {
    return _supabase.from('worker_locations').stream(primaryKey: ['worker_id']).eq('worker_id', workerId);
  }

  Stream<List<Map<String, dynamic>>> getAllWorkersLocationStream() {
    return _supabase.from('worker_locations').stream(primaryKey: ['worker_id']);
  }
}
