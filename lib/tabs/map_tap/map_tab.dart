import 'package:event/shared/app_theme.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/models/event_model.dart';
import 'package:event/provider/event_provider.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _isLoading = true;
  bool _isRefreshing = false;
  Set<Marker> _markers = {};
  List<EventModel> _allEvents = [];
  List<EventModel> _eventsWithLocation = [];

  // Animation controllers
  late AnimationController _loadingController;
  late AnimationController _statsController;

  // Statistics
  int _totalEvents = 0;
  int _eventsWithLocations = 0;
  int _eventsWithoutLocations = 0;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isDark = Provider.of<SettingsProvider>(
        context,
        listen: false,
      ).isDark;
      _loadEvents(isDark: isDark);
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _statsController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadEvents({required bool isDark}) async {
    if (!_isLoading) {
      setState(() => _isRefreshing = true);
    }

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.getEvents();

    _allEvents = eventProvider.allEvents;
    _calculateStatistics();
    await _createMarkers(events: _allEvents, isDark: isDark);

    setState(() {
      _isLoading = false;
      _isRefreshing = false;
    });

    // Start stats animation
    _statsController.forward();
  }

  void _calculateStatistics() {
    _totalEvents = _allEvents.length;
    _eventsWithLocations = _allEvents
        .where((event) => event.location != null)
        .length;
    _eventsWithoutLocations = _totalEvents - _eventsWithLocations;
  }

  Future<void> _createMarkers({
    required List<EventModel> events,
    required bool isDark,
  }) async {
    final markers = <Marker>{};
    _eventsWithLocation = events
        .where((event) => event.location != null)
        .toList();

    for (final EventModel event in _eventsWithLocation) {
      markers.add(
        Marker(
          markerId: MarkerId(event.id),
          position: event.location!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: event.title,
            snippet: _formatEventSnippet(event),
          ),
          onTap: () {
            _showEventDetails(event: event, isDark: isDark);
          },
        ),
      );
    }

    setState(() {
      _markers = markers;
    });

    if (_eventsWithLocation.isNotEmpty) {
      _fitMarkersToScreen();
    }
  }

  String _formatEventSnippet(EventModel event) {
    final date = DateFormat('MMM d').format(event.dateTime);
    final time = DateFormat('h:mm a').format(event.dateTime);
    return '📅$date - ⏰$time  Tap for details';
  }

  void _showEventDetails({required EventModel event, required bool isDark}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildEventDetailsSheet(event: event, isDark: isDark),
    );
  }

  Widget _buildEventDetailsSheet({
    required EventModel event,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category color
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        event.categoryModel.label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Description
            if (event.description.isNotEmpty) ...[
              Text(
                'Description',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 16),
            ],

            // Date & Time
            Row(
              children: [
                SizedBox(width: 8),
                Text(
                  '📅 Date & Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'EEEE, MMMM d, yyyy • h:mm a',
                    ).format(event.dateTime),
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall!.copyWith(color: AppTheme.primary),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Location
            if (event.location != null) ...[
              Row(
                children: [
                  SizedBox(width: 8),
                  Text(
                    '📍Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.place, size: 16, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.address ??
                            '${event.location!.latitude.toStringAsFixed(6)}, ${event.location!.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 20),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: CustomElevatedButton(
                color: isDark
                    ? AppTheme.primary.withValues(alpha: .5)
                    : AppTheme.primary,
                textElevatedButton: 'Close Details',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fitMarkersToScreen() {
    if (_mapController != null && _markers.isNotEmpty) {
      final bounds = _calculateBounds();
      Future.delayed(Duration(milliseconds: 500), () {
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      });
    }
  }

  LatLngBounds _calculateBounds() {
    if (_eventsWithLocation.isEmpty) {
      return LatLngBounds(
        southwest: LatLng(29.0, 30.0),
        northeast: LatLng(31.0, 32.0),
      );
    }

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final event in _eventsWithLocation) {
      final lat = event.location!.latitude;
      final lng = event.location!.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    // Add some padding
    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;

    return LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );
  }

  Widget _buildStatisticsDialog({required bool isDark}) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primary.withValues(alpha: .7)
                    : AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics,
                    size: 24,
                    color: AppTheme.backgroundWhite,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Events Statistics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.backgroundWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Statistics Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.event, size: 30, color: AppTheme.primary),
                          SizedBox(height: 8),
                          Text(
                            _totalEvents.toString(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Total Events',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: AppTheme.primary.withValues(alpha: 0.3)),
            ),

            // Events List Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.list, size: 25, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text(
                    'All Events (${_allEvents.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Tap to view on map',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDark
                          ? AppTheme.backgroundWhite.withValues(alpha: .7)
                          : AppTheme.black.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Events List
            Expanded(
              child: _allEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: AppTheme.black.withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No events found',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.black.withValues(alpha: 0.5),
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _allEvents.length,
                      itemBuilder: (context, index) {
                        final event = _allEvents[index];
                        return _buildEventListItem(event, index, isDark);
                      },
                    ),
            ),

            // Close Button
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  color: isDark
                      ? AppTheme.primary.withValues(alpha: .5)
                      : AppTheme.primary,
                  textElevatedButton: 'Close',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventListItem(EventModel event, int index, bool isDark) {
    final hasLocation = event.location != null;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: hasLocation ? () => _navigateToEventLocation(event) : null,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasLocation
                  ? AppTheme.primary.withValues(alpha: 0.05)
                  : AppTheme.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasLocation
                    ? AppTheme.primary.withValues(alpha: 0.2)
                    : AppTheme.black.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                // Event Number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: hasLocation
                        ? AppTheme.primary
                        : AppTheme.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.backgroundWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // Event Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: hasLocation
                                  ? AppTheme.primary
                                  : AppTheme.black.withValues(alpha: 0.6),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: isDark
                                ? AppTheme.backgroundWhite.withValues(alpha: .5)
                                : AppTheme.black.withValues(alpha: 0.5),
                          ),
                          SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(event.dateTime),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 14,

                                  color: isDark
                                      ? AppTheme.backgroundWhite.withValues(
                                          alpha: .8,
                                        )
                                      : AppTheme.black.withValues(alpha: 0.6),
                                ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isDark
                                ? AppTheme.backgroundWhite.withValues(alpha: .5)
                                : AppTheme.black.withValues(alpha: 0.5),
                          ),
                          SizedBox(width: 4),
                          Text(
                            DateFormat('h:mm a').format(event.dateTime),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppTheme.backgroundWhite.withValues(
                                          alpha: .8,
                                        )
                                      : AppTheme.black.withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            hasLocation
                                ? Icons.location_on
                                : Icons.location_off,
                            size: 12,
                            color: hasLocation ? Colors.green : Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hasLocation
                                  ? (event.address ?? 'Location available')
                                  : 'No location',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: hasLocation
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Navigation Icon
                if (hasLocation) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEventLocation(EventModel event) {
    // Close the dialog first
    Navigator.pop(context);

    // Then navigate to the event location
    if (event.location != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: event.location!,
            zoom: 15.0,
            bearing: 0,
            tilt: 0,
          ),
        ),
      );

      // Show a snackbar to indicate navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_on, color: AppTheme.backgroundWhite),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Navigated to: ${event.title}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.primary,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<SettingsProvider>(context).isDark;

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(30.0444, 31.2357),
              zoom: 10,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },

            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            buildingsEnabled: true,
            trafficEnabled: false,
            mapType: MapType.normal,
          ),

          // Loading Overlay
          if (_isLoading) _buildLoadingOverlay(isDark: isDark),

          // Top Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildTopControls(isDark: isDark),
          ),

          // Refresh Indicator
          if (_isRefreshing) _buildRefreshIndicator(isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay({required bool isDark}) {
    return Container(
      color: AppTheme.primary.withValues(alpha: .1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3),
            SizedBox(height: 20),
            Text(
              'Loading Events Map...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.primary),
            ),
            SizedBox(height: 8),
            Text(
              'Finding all your event locations',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.primary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls({required bool isDark}) {
    return Row(
      children: [
        // Statistics Button
        Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: MediaQuery.sizeOf(context).height * .08,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.backgroundDark
                  : AppTheme.backgroundWhite,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        _buildStatisticsDialog(isDark: isDark),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Row(
                    children: [
                      Icon(Icons.analytics, color: AppTheme.primary, size: 30),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Events',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppTheme.primary),
                            ),
                            Text(
                              '$_eventsWithLocations on map',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        // Refresh Button
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundWhite,

            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppTheme.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                _loadEvents(isDark: isDark);
              },
              child: Icon(Icons.refresh, color: AppTheme.primary, size: 30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshIndicator({required bool isDark}) {
    return Positioned(
      top: MediaQuery.sizeOf(context).height * .2,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.backgroundDark.withValues(alpha: .8)
                : AppTheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? AppTheme.primary : AppTheme.backgroundWhite,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Updating events...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? AppTheme.primary : AppTheme.backgroundWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
