import 'package:event/app_theme.dart';
import 'package:event/components/custom_create_eventrow.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/home_tab/tab_item.dart';
import 'package:event/models/category_model.dart';
import 'package:event/models/event_model.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/utilis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateEventScreen extends StatefulWidget {
  final EventModel? eventModel;
  const UpdateEventScreen({super.key, this.eventModel});

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

  @override
  void initState() {
    super.initState();
    widget.eventModel != null
        ? currentIndex = int.parse(widget.eventModel!.categoryModel.id) - 1
        : 0;

    titleController!.text = widget.eventModel!.title;
    descriptionController!.text = widget.eventModel!.description;
    selectedDate = widget.eventModel!.dateTime;
    selectedTime = TimeOfDay.fromDateTime(widget.eventModel!.dateTime);
  }

  @override
  Widget build(BuildContext context) {
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
                        selectedBackgroundColor: AppTheme.primary,
                        unSelectedBackgroundColor: AppTheme.backgroundWhite,
                        foreginSelectedColor: AppTheme.backgroundWhite,
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
                        color: AppTheme.black,
                      ),
                    ),
                    CustomTextFormField(
                      hintText: widget.eventModel!.title,

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
                      controller: descriptionController,
                      maxLines: 4,
                      hintText: widget.eventModel!.description,
                    ),
                    CustomCreateEventRow(
                      textTheme: textTheme,
                      label: 'Date',
                      iconName: 'date',
                      date: selectedDate ?? widget.eventModel!.dateTime,
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
                          TimeOfDay.fromDateTime(widget.eventModel!.dateTime),
                      onPressed: () async {
                        selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        setState(() {});
                      },
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
          id: widget.eventModel!.id,
        );
        FirebaseService.updateEvent(eventModel)
            .then((_) {
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
