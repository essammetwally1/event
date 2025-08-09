import 'package:event/components/event_item.dart';
import 'package:event/home_tab/home_header.dart';
import 'package:event/provider/event_provider.dart';
import 'package:event/screens/event_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    EventProvider eventProvider = Provider.of<EventProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          HomeHeader(),
          SizedBox(height: 16),
          eventProvider.filteredEvents.isNotEmpty
              ? Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (_, index) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return EventItemScreen(
                                eventModel: eventProvider.filteredEvents[index],
                              );
                            },
                          ),
                        );
                      },
                      child: EventItem(
                        event: eventProvider.filteredEvents[index],
                      ),
                    ),
                    separatorBuilder: (_, _) => SizedBox(height: 8),
                    itemCount: eventProvider.filteredEvents.length,
                  ),
                )
              : Text(''),
        ],
      ),
    );
  }
}
