// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum LocationState {
  success,
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class LocationResult {
  final LocationState state;
  final LatLng? latLng;
  final String message;

  const LocationResult({
    required this.state,
    required this.message,
    this.latLng,
  });

  bool get isSuccess => state == LocationState.success && latLng != null;
}

class LocationService {
  static Future<LocationResult> fetchDeviceLocation({
    LocationAccuracy accuracy = LocationAccuracy.best,
  }) async {
    try {
      final bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return const LocationResult(
          state: LocationState.servicesDisabled,
          message: 'Location services disabled',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            state: LocationState.permissionDenied,
            message: 'Location permission denied',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          state: LocationState.permissionDeniedForever,
          message: 'Location permission permanently denied',
        );
      }

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      );

      return LocationResult(
        state: LocationState.success,
        message:
            'OK (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})',
        latLng: LatLng(pos.latitude, pos.longitude),
      );
    } catch (e) {
      return LocationResult(
        state: LocationState.error,
        message: 'Error getting location: $e',
      );
    }
  }
}
