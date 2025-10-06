// lib/screens/map_picker_screen.dart
import 'package:event/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng initial;
  const MapPickerScreen({super.key, required this.initial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _picked;
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initial,
              zoom: 13.5,
            ),
            onMapCreated: (c) => _controller = c,
            onTap: (pos) => setState(() => _picked = pos),
            markers: {
              if (_picked != null)
                Marker(markerId: const MarkerId('picked'), position: _picked!),
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back_ios, color: AppTheme.primary),
                  Text(
                    'Pick Location',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(),
                    onPressed: _picked == null
                        ? null
                        : () => Navigator.pop(context, _picked),
                    child: const Text('DONE'),
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
