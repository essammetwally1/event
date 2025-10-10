import 'package:event/shared/app_theme.dart';
import 'package:event/components/custom_create_eventrow.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/services/firebase_service.dart';
import 'package:event/screens/map_pikcer_screen.dart';
import 'package:event/tabs/home_tab/tab_item.dart';
import 'package:event/models/category_model.dart';
import 'package:event/models/event_model.dart';
import 'package:event/provider/event_provider.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/shared/utilis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// REMOVE direct geolocator import from screen; logic is in the service now
// import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// NEW: import the service
import 'package:event/services/location_service.dart';

class CreateEventScreen extends StatefulWidget {
  static const String routeName = '/createevent';
  final EventModel? eventModel;
  const CreateEventScreen({super.key, this.eventModel});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  int currentIndex = 0;
  TextEditingController? titleController = TextEditingController();
  TextEditingController? descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  LatLng? _pickedLatLng;
  String? _pickedAddress;
  bool _isGettingLocation = true;

  // NEW: track permission/services state
  LocationState? _locationState;

  @override
  void initState() {
    super.initState();
    widget.eventModel != null
        ? currentIndex = int.parse(widget.eventModel!.categoryModel.id) - 1
        : 0;

    _getDeviceLatLng();
  }

  // REFACTORED: use the service only; screen decides UI
  Future<void> _getDeviceLatLng() async {
    setState(() => _isGettingLocation = true);

    final LocationResult res = await LocationService.fetchDeviceLocation();

    if (!mounted) return;

    setState(() {
      _isGettingLocation = false;
      _locationState = res.state;

      if (res.isSuccess) {
        _pickedLatLng = res.latLng!;
        _pickedAddress =
            '${res.latLng!.latitude.toStringAsFixed(4)}, ${res.latLng!.longitude.toStringAsFixed(4)}';
      } else {
        _pickedAddress = res.message;

        // Optional: silent fallback coordinate (e.g., Cairo) on hard failures
        if (res.state == LocationState.error ||
            res.state == LocationState.servicesDisabled) {
          _pickedLatLng = const LatLng(30.0444, 31.2357);
        }
      }
    });
  }

  bool get _canOpenMap => _locationState == LocationState.success;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDark = Provider.of<SettingsProvider>(context).isDark;

    // Decide dynamic color: primary if success, red otherwise
    final Color locColor = _locationState == LocationState.success
        ? AppTheme.primary
        : AppTheme.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 16),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/categoreis/${CategoryModel.categoryList[currentIndex].imageName}.png',
                  height: MediaQuery.sizeOf(context).height * .25,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 10),
            DefaultTabController(
              length: CategoryModel.categoryList.length,
              child: TabBar(
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                isScrollable: true,
                labelPadding: const EdgeInsets.only(right: 10),
                onTap: (index) {
                  if (currentIndex == index) return;
                  setState(() => currentIndex = index);
                },
                tabs: CategoryModel.categoryList
                    .map(
                      (category) => TabItem(
                        label: category.label,
                        icon: category.icon,
                        isSelected:
                            currentIndex ==
                            CategoryModel.categoryList.indexOf(category),
                        selectedBackgroundColor: AppTheme.primary,
                        unSelectedBackgroundColor: isDark
                            ? AppTheme.backgroundDark
                            : AppTheme.backgroundWhite,
                        foreginSelectedColor: isDark
                            ? AppTheme.black
                            : AppTheme.backgroundWhite,
                        foreginUnSelectedColor: AppTheme.primary,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Form(
                key: globalKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title',
                      style: textTheme.titleMedium!.copyWith(
                        color: isDark
                            ? AppTheme.backgroundWhite
                            : AppTheme.black,
                      ),
                    ),
                    CustomTextFormField(
                      isDark: isDark,
                      hintText: widget.eventModel != null
                          ? widget.eventModel!.title
                          : 'Event Title',
                      iconPathName: 'titleEvent',
                      controller: titleController,
                      validator: (value) {
                        if ((value ?? '').trim().length < 10) {
                          return 'Title should more than 10 letters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Event Description',
                      style: textTheme.titleMedium!.copyWith(
                        color: isDark
                            ? AppTheme.backgroundWhite
                            : AppTheme.black,
                      ),
                    ),
                    CustomTextFormField(
                      isDark: isDark,
                      controller: descriptionController,
                      maxLines: 4,
                      hintText: widget.eventModel != null
                          ? widget.eventModel!.description
                          : 'Description',
                    ),
                    // ===== Date Picker =====
                    CustomCreateEventRow(
                      textTheme: textTheme,
                      label: 'Date',
                      iconName: 'date',
                      date: selectedDate,
                      onPressed: () async {
                        final bool isDark = Provider.of<SettingsProvider>(
                          context,
                          listen: false,
                        ).isDark;

                        selectedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          initialDate: selectedDate ?? DateTime.now(),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppTheme
                                      .primary, // header and selected day
                                  onPrimary: Colors.white, // text on primary
                                  surface: isDark
                                      ? AppTheme.backgroundDark
                                      : AppTheme.backgroundWhite,
                                  onSurface: isDark
                                      ? AppTheme.backgroundWhite
                                      : AppTheme.black,
                                ),
                                dialogTheme: DialogThemeData(
                                  backgroundColor: isDark
                                      ? AppTheme.backgroundDark
                                      : AppTheme.backgroundWhite,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        setState(() {});
                      },
                    ),

                    // ===== Time Picker =====
                    CustomCreateEventRow(
                      textTheme: textTheme,
                      label: 'Time',
                      iconName: 'time',
                      time: selectedTime,
                      onPressed: () async {
                        final bool isDark = Provider.of<SettingsProvider>(
                          context,
                          listen: false,
                        ).isDark;

                        selectedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppTheme
                                      .primary, // clock hand & OK button
                                  onPrimary: Colors.white, // text on primary
                                  surface: isDark
                                      ? AppTheme.backgroundDark
                                      : AppTheme.backgroundWhite,
                                  onSurface: isDark
                                      ? AppTheme.backgroundWhite
                                      : AppTheme.black,
                                ),
                                timePickerTheme: TimePickerThemeData(
                                  dialBackgroundColor: isDark
                                      ? AppTheme.backgroundDark
                                      : AppTheme.backgroundWhite,
                                  dialHandColor: AppTheme.primary,
                                  hourMinuteTextColor: isDark
                                      ? AppTheme.backgroundWhite
                                      : AppTheme.black,
                                  entryModeIconColor: AppTheme.primary,
                                ),
                                dialogTheme: DialogThemeData(
                                  backgroundColor: isDark
                                      ? AppTheme.backgroundDark
                                      : AppTheme.backgroundWhite,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        setState(() {});
                      },
                    ),

                    // ===== Location Picker Section (color + tap behavior) =====
                    InkWell(
                      // Disable tap when location not enabled/allowed
                      onTap: !_canOpenMap
                          ? null
                          : () async {
                              final LatLng initial =
                                  _pickedLatLng ??
                                  const LatLng(30.0444, 31.2357);

                              final result = await Navigator.push<LatLng>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapPickerScreen(
                                    initial: initial,
                                    isSelected: false,
                                  ),
                                ),
                              );

                              if (result != null) {
                                setState(() {
                                  _pickedLatLng = result;
                                  _pickedAddress =
                                      '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
                                  _locationState =
                                      LocationState.success; // now good
                                });
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(top: 5, bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: locColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color:
                                    locColor, // primary on success, red otherwise
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/pickLocation.svg',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _isGettingLocation
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: locColor, // reflect state
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Getting your location...',
                                          style: textTheme.titleMedium,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _canOpenMap
                                              ? 'Tap to select other location'
                                              : 'Location not available',
                                          style: textTheme.titleMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          (_pickedAddress ?? '').isEmpty
                                              ? (_canOpenMap
                                                    ? 'Location ready'
                                                    : 'Enable location to continue')
                                              : _pickedAddress!,
                                          style: textTheme.titleSmall!.copyWith(
                                            color: locColor, // primary or red
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: locColor),
                          ],
                        ),
                      ),
                    ),

                    // ===== End Location Picker Section =====
                    CustomElevatedButton(
                      isLoading: isLoading,
                      textElevatedButton: 'Add Event',
                      onPressed: () {
                        addEvent(isDark: isDark);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addEvent({required bool isDark}) {
    if (_pickedLatLng == null) return;
    if (globalKey.currentState!.validate()) {
      if (selectedDate == null || selectedTime == null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: isDark
                ? AppTheme.backgroundDark
                : AppTheme.backgroundWhite,
            title: Text(
              'Select Time & Date',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: AppTheme.primary),
            ),
            content: Text(
              'Please select both date and time for your event.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: isDark ? AppTheme.backgroundWhite : AppTheme.black,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (isLoading == false) {
        setState(() => isLoading = true);
      }

      final DateTime dateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final EventModel eventModel = EventModel(
        userId: FirebaseAuth.instance.currentUser!.uid,
        title: titleController!.text,
        description: descriptionController!.text,
        categoryModel: CategoryModel.categoryList[currentIndex],
        dateTime: dateTime,
        location: _pickedLatLng!,
        address: _pickedAddress,
      );

      FirebaseService.createEvent(eventModel)
          .then((_) {
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            Utils.showSuccessMessage('Event Created Successfully');
            Provider.of<EventProvider>(context, listen: false).getEvents();
          })
          .catchError((error) {
            setState(() => isLoading = false);
            String? message;
            if (error is FirebaseException) message = error.message;
            Utils.showErrorMessage(message ?? 'Failed to create event');
          });
    }
  }
}
