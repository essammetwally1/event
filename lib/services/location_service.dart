import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // ✅ new import for reverse geocoding

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

  // ✅ New: Get human-readable address from LatLng
  static Future<String> getAddressFromLatLng(LatLng latLng) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark p = placemarks.first;

        // Prefer short form: "Street, City" or "City, Country"
        final String? street = (p.street != null && p.street!.isNotEmpty)
            ? p.street
            : null;
        final String? city = (p.locality != null && p.locality!.isNotEmpty)
            ? p.locality
            : null;
        final String? area =
            (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            ? p.administrativeArea
            : null;
        final String? country = (p.country != null && p.country!.isNotEmpty)
            ? p.country
            : null;

        // Compose small readable version — prioritizing city-level info
        String smallAddress = '';
        if (street != null && city != null) {
          smallAddress = '$street, $city';
        } else if (city != null && area != null) {
          smallAddress = '$city, $area';
        } else if (area != null && country != null) {
          smallAddress = '$area, $country';
        } else if (city != null && country != null) {
          smallAddress = '$city, $country';
        } else {
          smallAddress =
              '${latLng.latitude.toStringAsFixed(4)}, '
              '${latLng.longitude.toStringAsFixed(4)}';
        }

        return smallAddress;
      } else {
        return '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      return 'Unknown (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})';
    }
  }
}
