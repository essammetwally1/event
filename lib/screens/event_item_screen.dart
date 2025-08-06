import 'package:event/app_theme.dart';
import 'package:event/components/action_icon_button.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/models/event_model.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/screens/update_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class EventItemScreen extends StatelessWidget {
  static const String routeName = '/eventitemscreen';
  final EventModel eventModel;

  const EventItemScreen({super.key, required this.eventModel});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        actions: [
          ActionIconButton(
            iconPath: 'edit',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return UpdateEventScreen(eventModel: eventModel);
                  },
                ),
              );
            },
          ),
          ActionIconButton(
            iconPath: 'delete',
            onPressed: () {
              deleteEvent(eventModel.id, textTheme, context);
            },
          ),
        ],
        title: Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/categoreis/${eventModel.categoryModel.imageName}.png',
                height: MediaQuery.sizeOf(context).height * .25,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 8),
            Text(
              eventModel.title,
              style: textTheme.headlineSmall!.copyWith(color: AppTheme.primary),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: BoxBorder.all(color: AppTheme.primary, width: 1),
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
                        DateFormat('d, MMM, yyyy').format(eventModel.dateTime),
                        style: textTheme.titleMedium!.copyWith(
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(eventModel.dateTime),
                        style: textTheme.titleMedium!.copyWith(
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Description',
              style: textTheme.titleMedium!.copyWith(color: AppTheme.black),
            ),
            Text(
              eventModel.description,
              style: textTheme.titleSmall!.copyWith(color: AppTheme.black),
            ),
          ],
        ),
      ),
    );
  }

  void deleteEvent(String eventId, TextTheme textTheme, context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Event',
          style: textTheme.titleLarge!.copyWith(color: AppTheme.primary),
        ),
        content: Text(
          'Are you sure you want to delete this event?',
          style: textTheme.titleLarge!.copyWith(color: AppTheme.black),
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
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: textTheme.titleMedium!.copyWith(color: AppTheme.red),
            ),
          ),
        ],
      ),
    );

    confirmed == true ? FirebaseService.deleteEvent(eventId) : null;
    Navigator.of(context).pushNamed(HomeScreen.routeName);
  }
}
