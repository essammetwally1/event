import 'package:event/app_theme.dart';
import 'package:event/components/action_icon_button.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/models/event_model.dart';
import 'package:event/provider/event_provider.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/screens/update_event_screen.dart';
import 'package:event/utilis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventItemScreen extends StatefulWidget {
  static const String routeName = '/eventitemscreen';
  final EventModel eventModel;

  const EventItemScreen({super.key, required this.eventModel});

  @override
  State<EventItemScreen> createState() => _EventItemScreenState();
}

class _EventItemScreenState extends State<EventItemScreen> {
  bool _showMapPreview = false;
  GoogleMapController? _mapController;
  bool _isMapLoading = false;
  bool _isMapReady = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Smooth camera movement methods
  void _smoothMoveToLocation({
    required LatLng target,
    double zoom = 15.0,
    double bearing = 0.0,
    double tilt = 0.0,
    int durationMs = 1000,
  }) {
    if (_mapController != null && _isMapReady) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: zoom,
            bearing: bearing,
            tilt: tilt,
          ),
        ),
        duration: Duration(milliseconds: durationMs),
      );
    }
  }

  void _smoothZoomIn({int durationMs = 500}) {
    if (_mapController != null && _isMapReady) {
      _mapController!.animateCamera(
        CameraUpdate.zoomIn(),
        duration: Duration(milliseconds: durationMs),
      );
    }
  }

  void _smoothZoomOut({int durationMs = 500}) {
    if (_mapController != null && _isMapReady) {
      _mapController!.animateCamera(
        CameraUpdate.zoomOut(),
        duration: Duration(milliseconds: durationMs),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDark = Provider.of<SettingsProvider>(context).isDark;

    return Scaffold(
      appBar: AppBar(
        actions:
            FirebaseAuth.instance.currentUser?.uid == widget.eventModel.userId
            ? [
                ActionIconButton(
                  iconPath: 'edit',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return UpdateEventScreen(
                            eventModel: widget.eventModel,
                          );
                        },
                      ),
                    );
                  },
                ),
                ActionIconButton(
                  iconPath: 'delete',
                  onPressed: () {
                    deleteEvent(widget.eventModel.id, textTheme, context);
                  },
                ),
              ]
            : [],

        title: Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          // Allow normal scrolling for the entire page
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/categoreis/${widget.eventModel.categoryModel.imageName}.png',
                height: MediaQuery.sizeOf(context).height * .25,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Title :',
              style: textTheme.headlineSmall!.copyWith(
                color: isDark ? AppTheme.backgroundWhite : AppTheme.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              textAlign: TextAlign.center,
              widget.eventModel.title,
              style: textTheme.titleLarge!.copyWith(
                color: isDark ? AppTheme.backgroundWhite : AppTheme.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Description :',
              style: textTheme.headlineSmall!.copyWith(
                color: isDark ? AppTheme.backgroundWhite : AppTheme.black,
              ),
            ),
            Text(
              textAlign: TextAlign.center,
              widget.eventModel.description,
              style: textTheme.titleLarge!.copyWith(
                color: isDark ? AppTheme.backgroundWhite : AppTheme.black,
              ),
            ),
            SizedBox(height: 8),

            // Date & Time Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppTheme.primary,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/date.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        AppTheme.backgroundWhite,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat(
                          'd, MMM, yyyy',
                        ).format(widget.eventModel.dateTime),
                        style: textTheme.titleMedium!.copyWith(
                          color: isDark
                              ? AppTheme.backgroundWhite
                              : AppTheme.black,
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(widget.eventModel.dateTime),
                        style: textTheme.titleMedium!.copyWith(
                          color: isDark
                              ? AppTheme.backgroundWhite
                              : AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Location Section
            if (widget.eventModel.location != null) ...[
              // Location Button
              InkWell(
                onTap: () {
                  setState(() {
                    _showMapPreview = !_showMapPreview;
                    if (_showMapPreview) {
                      _isMapLoading = true;
                      _isMapReady = false;
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary, width: 2),
                    color: isDark
                        ? AppTheme.backgroundDark
                        : AppTheme.backgroundWhite,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.primary,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/pickLocation.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            AppTheme.backgroundWhite,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Event Location',
                              style: textTheme.titleMedium!.copyWith(
                                color: isDark
                                    ? AppTheme.backgroundWhite
                                    : AppTheme.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.eventModel.address ??
                                  _formatCoordinates(
                                    widget.eventModel.location!,
                                  ),
                              style: textTheme.titleSmall!.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _showMapPreview ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              // Google Maps Preview (Expanded Section)
              if (_showMapPreview) ...[
                SizedBox(height: 12),
                AnimatedContainer(
                  duration: Duration(milliseconds: 0),
                  height: 400, // Fixed height for map preview
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Solution: Use InteractiveViewer or GestureDetector to handle map gestures
                        _buildMapWithGestureHandling(isDark, textTheme),

                        // Loading Indicator
                        if (_isMapLoading)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.backgroundDark
                                      : AppTheme.backgroundWhite,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppTheme.primary,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Loading Map...',
                                      style: textTheme.titleMedium!.copyWith(
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Custom Map Controls Container
                        if (_isMapReady)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Column(
                              children: [
                                // Compass/Reset North
                                _buildMapControlButton(
                                  isDark: isDark,
                                  icon: Icons.explore,
                                  onPressed: () {
                                    _smoothMoveToLocation(
                                      target: widget.eventModel.location!,
                                      zoom: 15.0,
                                      bearing: 0,
                                      tilt: 0,
                                      durationMs: 800,
                                    );
                                  },
                                ),
                                SizedBox(height: 8),

                                // Zoom In
                                _buildMapControlButton(
                                  isDark: isDark,
                                  icon: Icons.add,
                                  onPressed: () {
                                    _smoothZoomIn(durationMs: 300);
                                  },
                                ),
                                SizedBox(height: 1),

                                // Zoom Out
                                _buildMapControlButton(
                                  isDark: isDark,
                                  icon: Icons.remove,
                                  onPressed: () {
                                    _smoothZoomOut(durationMs: 300);
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),
              ],
            ] else ...[
              // No Location Available
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.gray, width: 1),
                  color: isDark
                      ? AppTheme.backgroundDark
                      : AppTheme.backgroundWhite,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.gray,
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/pickLocation.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          AppTheme.backgroundWhite,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No location specified for this event',
                        style: textTheme.titleMedium!.copyWith(
                          color: isDark
                              ? AppTheme.backgroundWhite
                              : AppTheme.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Method to build map with proper gesture handling
  Widget _buildMapWithGestureHandling(bool isDark, TextTheme textTheme) {
    return GestureDetector(
      onTap: () {
        // Empty handler to capture taps
      },
      onTapDown: (_) {
        // Empty handler to capture taps
      },
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.eventModel.location!,
          zoom: 15.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          setState(() {
            _isMapReady = true;
            _isMapLoading = false;
          });

          // Auto-center on the location when map is ready
          Future.delayed(Duration(milliseconds: 300), () {
            if (mounted && _mapController != null) {
              _smoothMoveToLocation(
                target: widget.eventModel.location!,
                zoom: 15.0,
                durationMs: 800,
              );
            }
          });
        },
        markers: {
          Marker(
            markerId: MarkerId('event_location'),
            position: widget.eventModel.location!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Event Location',
              snippet:
                  widget.eventModel.address ??
                  _formatCoordinates(widget.eventModel.location!),
            ),
          ),
        },
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: false,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        buildingsEnabled: true,
        indoorViewEnabled: true,
        trafficEnabled: false,
        mapType: MapType.normal,
        // Important: Ensure map gestures work properly
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        }.toSet(),
      ),
    );
  }

  // Helper method for consistent control buttons
  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppTheme.primary, size: 30),
        padding: EdgeInsets.all(8),
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  String _formatCoordinates(LatLng location) {
    return 'Lat: ${location.latitude.toStringAsFixed(6)}\nLng: ${location.longitude.toStringAsFixed(6)}';
  }

  void deleteEvent(String eventId, TextTheme textTheme, context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Provider.of<SettingsProvider>(context).isDark
            ? AppTheme.backgroundDark
            : AppTheme.backgroundWhite,
        title: Text(
          'Delete Event',
          style: textTheme.titleLarge!.copyWith(color: AppTheme.primary),
        ),
        content: Text(
          'Are you sure you want to delete this event?',
          style: textTheme.titleMedium!.copyWith(
            color: Provider.of<SettingsProvider>(context).isDark
                ? AppTheme.backgroundWhite
                : AppTheme.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: textTheme.titleMedium!.copyWith(color: AppTheme.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<EventProvider>(context, listen: false).getEvents();
              Navigator.pop(context, true);
            },
            child: Text(
              'Delete',
              style: textTheme.titleMedium!.copyWith(color: AppTheme.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      FirebaseService.deleteEvent(eventId)
          .then((_) {
            Navigator.of(context).pushNamed(HomeScreen.routeName);
            Utils.showSuccessMessage('Event Deleted');
          })
          .catchError((error) {
            String? message;
            if (error is FirebaseException) {
              message = error.message;
            }
            Utils.showErrorMessage(message);
          });
    }
  }
}
