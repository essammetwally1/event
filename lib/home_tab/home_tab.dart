import 'package:event/components/event_item.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/home_tab/home_header.dart';
import 'package:event/models/event_model.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<EventModel>? events;

  Widget build(BuildContext context) {
    if (events == null) {
      getEvents();
    }
    return Scaffold(
      body: Column(
        children: [
          HomeHeader(),
          SizedBox(height: 16),
          events != null
              ? Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (_, index) => EventItem(event: events![index]),
                    separatorBuilder: (_, _) => SizedBox(height: 8),
                    itemCount: events!.length,
                  ),
                )
              : Text(''),
        ],
      ),
    );
  }

  Future<void> getEvents() async {
    events = await FirebaseService.getEvents();
    setState(() {});
  }
}
