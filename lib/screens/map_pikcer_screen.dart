// lib/screens/map_picker_screen.dart
import 'package:event/shared/app_theme.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initial;
  final bool isSelected;
  const MapPickerScreen({
    super.key,
    required this.initial,
    required this.isSelected,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _picked;
  LatLng? _current; // device location
  GoogleMapController? _controller;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    try {
      if (widget.isSelected == false) {
        final location = await _getDeviceLatLng();
        if (!mounted) return;

        setState(() {
          _current = location;
          _isLoadingLocation = false;
        });

        // If we have an initial location from parent, set it as picked initially
        if (widget.initial != null) {
          setState(() {
            _picked = widget.initial;
          });
        }

        // If we have current location, center map on it (only if no initial location)
        if (location != null && _controller != null && widget.initial == null) {
          _controller!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: location, zoom: 15),
            ),
          );
        }
      } else {
        _current = widget.initial!;
      }
    } catch (e) {
      print("Error getting current location: $e");
      setState(() => _isLoadingLocation = false);

      // Still set initial location as picked if available
      if (widget.initial != null) {
        setState(() {
          _picked = widget.initial;
        });
      }
    }
  }

  Future<LatLng?> _getDeviceLatLng() async {
    try {
      // Check if location service is enabled
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting device location: $e");
      return null;
    }
  }

  String _fmt(LatLng p) =>
      '${p.latitude.toStringAsFixed(3)} ${p.longitude.toStringAsFixed(3)}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDark = Provider.of<SettingsProvider>(context).isDark;

    // Determine initial camera position - prioritize the initial location from parent
    final initialPosition =
        widget.initial ?? _current ?? const LatLng(30.0444, 31.2357);

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          if (_isLoadingLocation)
            Container(
              color: isDark
                  ? AppTheme.backgroundDark
                  : AppTheme.backgroundWhite,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.backgroundDark
                            : AppTheme.backgroundWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppTheme.backgroundWhite.withValues(alpha: .2)
                                : AppTheme.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Loading Map...',
                            style: textTheme.titleLarge?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Opening at your selected location',

                            style: textTheme.titleSmall!.copyWith(
                              color: isDark
                                  ? null
                                  : AppTheme.black.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 10,
              ),
              onMapCreated: (controller) {
                _controller = controller;

                // If we have an initial location from parent, center on it
                if (widget.initial != null) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: widget.initial!,
                        zoom: 15,
                        bearing: 0,
                        tilt: 45,
                      ),
                    ),
                  );
                }
                // Otherwise center on current location if available
                else if (_current != null) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _current!,
                          zoom: 15,
                          bearing: 0,
                          tilt: 45,
                        ),
                      ),
                    );
                  });
                }
              },
              onTap: (pos) => setState(() => _picked = pos),
              markers: _buildMarkers(),
              myLocationEnabled: false,
              myLocationButtonEnabled: false, // We use custom button
              zoomControlsEnabled: false, // We use custom controls
              mapToolbarEnabled: false,
              compassEnabled: true, // Keep compass enabled
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              buildingsEnabled: true,
              indoorViewEnabled: true,
              trafficEnabled: false,
              mapType: MapType.normal,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 80,
                bottom: (_picked != null || widget.initial != null) ? 140 : 80,
              ),
            ),

          // Custom Top Bar
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.backgroundDark
                    : AppTheme.backgroundWhite,

                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () =>
                          Navigator.pop(context, _picked ?? widget.initial),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Title
                  Expanded(
                    child: Text(
                      'Select Event Location',
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Current Location Button
                  if (!_isLoadingLocation && _current != null)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _controller?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: _current!,
                                zoom: 15,
                                tilt: 45,
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.my_location,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  SizedBox(width: 5),

                  // Center on Initial Location Button (if different from current)
                  if (!_isLoadingLocation &&
                      widget.initial != null &&
                      _current != null &&
                      widget.initial != _current)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _controller?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: widget.initial!,
                                zoom: 15,
                                tilt: 45,
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.place,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Custom Zoom Controls
          if (!_isLoadingLocation)
            Positioned(
              top: MediaQuery.sizeOf(context).height * .15,
              right: 16,
              child: Column(
                children: [
                  // Zoom In
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.backgroundDark
                          : AppTheme.backgroundWhite,

                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _controller?.animateCamera(CameraUpdate.zoomIn());
                      },
                      icon: Icon(Icons.add, color: AppTheme.primary),
                    ),
                  ),

                  // Divider
                  Container(
                    height: 1,
                    width: 48,
                    color: AppTheme.primary.withValues(alpha: 0.5),
                  ),

                  // Zoom Out
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.backgroundDark
                          : AppTheme.backgroundWhite,

                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _controller?.animateCamera(CameraUpdate.zoomOut());
                      },
                      icon: Icon(Icons.remove, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Selection Card (shown when there's a picked location OR initial location)
          if ((_picked != null || widget.initial != null) &&
              !_isLoadingLocation)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                offset: (_picked != null || widget.initial != null)
                    ? Offset.zero
                    : const Offset(0, 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: (_picked != null || widget.initial != null)
                      ? 1.0
                      : 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.backgroundDark
                          : AppTheme.backgroundWhite,

                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.black.withValues(alpha: 0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.place,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Selected Location',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Coordinates
                        Text(
                          _fmt(_picked ?? widget.initial!),
                          style: textTheme.titleMedium?.copyWith(
                            color: AppTheme.primary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Done Button
                        SizedBox(
                          width: double.infinity,
                          child: Material(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: () => Navigator.pop(
                                context,
                                _picked ?? widget.initial,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Confirm Location',
                                      style: textTheme.titleMedium?.copyWith(
                                        color: isDark
                                            ? AppTheme.backgroundDark
                                            : AppTheme.backgroundWhite,

                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.check_circle,
                                      color: isDark
                                          ? AppTheme.backgroundDark
                                          : AppTheme.backgroundWhite,

                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Show marker for selected location (red)
    if (_picked != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('picked'),
          position: _picked!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: _fmt(_picked!),
          ),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }
    // Show marker for initial location (orange) if no new selection
    else if (widget.initial != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('initial'),
          position: widget.initial!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: const InfoWindow(title: 'Current Location'),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    // Show marker for current device location (blue)
    if (_current != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: _current!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Device Location'),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    return markers;
  }
}
