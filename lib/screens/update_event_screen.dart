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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class UpdateEventScreen extends StatefulWidget {
  final EventModel eventModel;
  const UpdateEventScreen({super.key, required this.eventModel});

  @override
  State<UpdateEventScreen> createState() => _UpdateEventScreenState();
}

class _UpdateEventScreenState extends State<UpdateEventScreen> {
  int currentIndex = 0;
  TextEditingController? titleController = TextEditingController();
  TextEditingController? descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  late LatLng _pickedLatLng;
  late String _pickedAddress;
  late bool isDark;

  @override
  void initState() {
    super.initState();
    currentIndex = int.parse(widget.eventModel.categoryModel.id) - 1;
    _pickedLatLng = widget.eventModel.location!;
    _pickedAddress = widget.eventModel.address!;
    titleController!.text = widget.eventModel.title;
    descriptionController!.text = widget.eventModel.description;
    selectedDate = widget.eventModel.dateTime;
    selectedTime = TimeOfDay.fromDateTime(widget.eventModel.dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<SettingsProvider>(context).isDark;

    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('Update Event')),
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
                        selectedBackgroundColor: isDark
                            ? AppTheme.primary
                            : AppTheme.backgroundWhite,
                        unSelectedBackgroundColor: isDark
                            ? AppTheme.backgroundDark
                            : AppTheme.primary,
                        foreginSelectedColor: isDark
                            ? AppTheme.black
                            : AppTheme.primary,
                        foreginUnSelectedColor: isDark
                            ? AppTheme.primary
                            : AppTheme.backgroundWhite,
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
                        color: AppTheme.black,
                      ),
                    ),
                    CustomTextFormField(
                      hintText: widget.eventModel.title,
                      isDark: isDark,

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
                        color: AppTheme.black,
                      ),
                    ),
                    CustomTextFormField(
                      isDark: isDark,
                      controller: descriptionController,
                      maxLines: 4,
                      hintText: widget.eventModel.description,
                    ),
                    CustomCreateEventRow(
                      textTheme: textTheme,
                      label: 'Date',
                      iconName: 'date',
                      date: selectedDate ?? widget.eventModel.dateTime,
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

                      time:
                          selectedTime ??
                          TimeOfDay.fromDateTime(widget.eventModel.dateTime),
                      onPressed: () async {
                        selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        setState(() {});
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        // Use the current picked location or device location as initial
                        final LatLng initial = _pickedLatLng;

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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tap to select other location',
                                    style: textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _pickedAddress,
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
                      textElevatedButton: 'Update Event',
                      onPressed: updateEvent,
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

  void updateEvent() {
    if (globalKey.currentState!.validate()) {
      if (selectedDate == null && selectedTime == null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.backgroundWhite,
            title: Text(
              'Selected Time & Date',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: AppTheme.primary),
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
      } else {
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
          id: widget.eventModel.id,
          address: _pickedAddress,
          location: _pickedLatLng,
        );
        FirebaseService.updateEvent(eventModel)
            .then((_) {
              Provider.of<EventProvider>(context, listen: false).getEvents();
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
              Utils.showSuccessMessage('Event Updated');
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
}
