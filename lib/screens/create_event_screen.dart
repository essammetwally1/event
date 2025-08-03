import 'package:event/app_theme.dart';
import 'package:event/components/custom_create_event_row.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/home_tab/tab_item.dart';
import 'package:event/models/category_model.dart';
import 'package:event/screens/home_screen.dart';
import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  static const String routeName = '/createevent';
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  int currentIndex = 0;
  bool rightDate = false;
  bool rightTime = false;
  DateTime? date;
  TimeOfDay? time;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
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
                      hintText: 'Event Title',
                      iconPathName: 'titleEvent',
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
                    CustomTextFormField(maxLines: 4, hintText: 'Description'),
                    CustomCreateEventRow(
                      textTheme: textTheme,
                      label: 'Date',
                      iconName: 'date',
                      onPressed: () async {
                        date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                        );
                        if (date != null) {
                          rightDate = true;
                          print(date);
                        }
                      },
                    ),
                    CustomCreateEventRow(
                      textTheme: textTheme,
                      label: 'Time',
                      iconName: 'time',
                      onPressed: () async {
                        time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          rightTime = true;
                          print(time);
                        }
                      },
                    ),

                    // Text(
                    //   'Location',
                    //   style: textTheme.titleMedium!.copyWith(
                    //     color: AppTheme.black,
                    //   ),
                    // ),
                    CustomElevatedButton(
                      textElevatedButton: 'Add Event',
                      onPressed: addEvent,
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

  void addEvent() {
    if (globalKey.currentState!.validate()) {
      if (!rightTime || !rightDate) {
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
        return;
      }

      print('done');
      print('____________________________');

      print(date);
      print(time);
      print('____________________________');
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    }
  }
}
