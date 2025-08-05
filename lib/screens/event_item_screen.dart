import 'package:event/components/action_icon_button.dart';
import 'package:event/models/event_model.dart';
import 'package:flutter/material.dart';

class EventItemScreen extends StatelessWidget {
  static const String routeName = '/eventitemscreen';
  final EventModel eventModel;

  const EventItemScreen({super.key, required this.eventModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ActionIconButton(iconPath: 'edit', onPressed: editEvent),
          ActionIconButton(iconPath: 'delete', onPressed: deleteEvent),
        ],
        title: Text('Event Details'),
      ),
    );
  }

  void deleteEvent() {}
  void editEvent() {}
}
