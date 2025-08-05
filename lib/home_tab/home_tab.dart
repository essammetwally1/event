import 'package:event/components/event_item.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/home_tab/home_header.dart';
import 'package:event/models/category_model.dart';
import 'package:event/models/event_model.dart';
import 'package:event/screens/event_item_screen.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<EventModel> filteredEvents = [];
  List<EventModel> allEvents = [];

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HomeHeader(filterEvents: filterEvents),
          SizedBox(height: 16),
          filteredEvents.isNotEmpty
              ? Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (_, index) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return EventItemScreen(
                                eventModel: filteredEvents[index],
                              );
                            },
                          ),
                        );
                      },
                      child: EventItem(event: filteredEvents[index]),
                    ),
                    separatorBuilder: (_, _) => SizedBox(height: 8),
                    itemCount: filteredEvents.length,
                  ),
                )
              : Text(''),
        ],
      ),
    );
  }

  Future<void> getEvents() async {
    allEvents = await FirebaseService.getEvents();
    filteredEvents = allEvents;
    setState(() {});
  }

  void filterEvents(CategoryModel? categoryModel) {
    categoryModel == null
        ? filteredEvents = allEvents
        : filteredEvents = allEvents
              .where((event) => event.categoryModel == categoryModel)
              .toList();
    setState(() {});
  }
}
