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
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  // late bool isDark;

  @override
  void initState() {
    super.initState();
    widget.eventModel != null
        ? currentIndex = int.parse(widget.eventModel!.categoryModel.id) - 1
        : 0;

    // Initialize with device location
    _getDeviceLatLng();
  }

  Future<void> _getDeviceLatLng() async {
    try {
      setState(() {
        _isGettingLocation = true;
      });

      // Check if location service is enabled
      final bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) {
          setState(() {
            _isGettingLocation = false;
            _pickedAddress = 'Location services disabled';
          });
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isGettingLocation = false;
              _pickedAddress = 'Location permission denied';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isGettingLocation = false;
            _pickedAddress = 'Location permission permanently denied';
          });
        }
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
      );

      if (mounted) {
        setState(() {
          _pickedLatLng = LatLng(position.latitude, position.longitude);
          _pickedAddress =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          _isGettingLocation = false;
        });
      }
    } catch (e) {
      print("Error getting location: $e");
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
          _pickedAddress = 'Error getting location';
          // Set default location as fallback
          _pickedLatLng = const LatLng(30.0444, 31.2357);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDark = Provider.of<SettingsProvider>(context).isDark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
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
            SizedBox(height: 10),
            DefaultTabController(
              length: CategoryModel.categoryList.length,

              child: TabBar(
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                isScrollable: true,
                labelPadding: EdgeInsets.only(right: 10),
                onTap: (index) {
                  if (currentIndex == index) return;
                  setState(() {
                    currentIndex = index;
                  });
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
            SizedBox(height: 16),
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
                        if (value!.length < 10) {
                          return 'Title should more than 10 letters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
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
                    CustomCreateEventRow(
                      textTheme: textTheme,
                      label: 'Date',
                      iconName: 'date',
                      date: selectedDate ?? selectedDate,
                      onPressed: () async {
                        selectedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                        );
                        setState(() {});
                      },
                    ),
                    CustomCreateEventRow(
                      textTheme: textTheme,
                      label: 'Time',
                      iconName: 'time',

                      time: selectedTime ?? selectedTime,
                      onPressed: () async {
                        selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        setState(() {});
                      },
                    ),

                    // Location Picker Section
                    InkWell(
                      onTap: () async {
                        // Use the current picked location or device location as initial
                        final LatLng initial =
                            _pickedLatLng ?? const LatLng(30.0444, 31.2357);

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
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(top: 5, bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primary, width: 2),
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
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _isGettingLocation
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                        SizedBox(width: 8),
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
                                          'Tap to select other location',
                                          style: textTheme.titleMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _pickedAddress!,
                                          style: textTheme.titleSmall!.copyWith(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),

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
                style: TextButton.styleFrom(),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (_pickedLatLng == null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.backgroundWhite,
            title: Text(
              'Select Location',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: AppTheme.primary),
            ),
            content: Text(
              'Please select a location for your event.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (isLoading == false) {
        setState(() {
          isLoading = true;
        });
      }

      DateTime dateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      EventModel eventModel = EventModel(
        userId: FirebaseAuth.instance.currentUser!.uid,
        title: titleController!.text,
        description: descriptionController!.text,
        categoryModel: CategoryModel.categoryList[currentIndex],
        dateTime: dateTime,
        location: _pickedLatLng!, // Add location
        address: _pickedAddress, // Add address
      );

      FirebaseService.createEvent(eventModel)
          .then((_) {
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            Utils.showSuccessMessage('Event Created Successfully');
            Provider.of<EventProvider>(context, listen: false).getEvents();
          })
          .catchError((error) {
            setState(() {
              isLoading = false;
            });
            String? message;
            if (error is FirebaseException) {
              message = error.message;
            }
            Utils.showErrorMessage(message ?? 'Failed to create event');
          });
    }
  }
}
