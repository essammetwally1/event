import 'package:event/components/custom_textfield.dart';
import 'package:event/components/event_item.dart';
import 'package:event/provider/event_provider.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoveTab extends StatefulWidget {
  static const String routeName = '/love';
  const LoveTab({super.key});

  @override
  State<LoveTab> createState() => _LoveTabState();
}

class _LoveTabState extends State<LoveTab> {
  late EventProvider eventProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<String> favouriteIds = Provider.of<UserProvider>(
        context,
        listen: false,
      ).currentUser!.favouriteEventsIds;
      eventProvider.filterFavouriteEvents(favouriteIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<SettingsProvider>(context).isDark;

    eventProvider = Provider.of<EventProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CustomTextFormField(
                isDark: isDark,

                hintText: 'Search For Event',
                iconPathName: 'search',

                onChange: (query) {},
              ),
            ),
            SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (_, index) =>
                    EventItem(event: eventProvider.favouriteEvents[index]),
                separatorBuilder: (_, _) => SizedBox(height: 8),
                itemCount: eventProvider.favouriteEvents.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
