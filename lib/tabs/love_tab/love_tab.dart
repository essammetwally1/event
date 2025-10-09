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
  VoidCallback? _userListener;

  @override
  void initState() {
    super.initState();
    // defer until providers are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(
        context,
        listen: false,
      ).currentUser;
      eventProvider = Provider.of<EventProvider>(context, listen: false);
      if (user != null) {
        eventProvider.filterFavouriteEvents(user.favouriteEventsIds);
      }
      // listen for any later changes to favourites
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _userListener = () {
        final u = userProvider.currentUser;
        if (u != null) {
          eventProvider.filterFavouriteEvents(u.favouriteEventsIds);
        } else {
          eventProvider.filterFavouriteEvents(const []);
        }
      };
      userProvider.addListener(_userListener!);
    });
  }

  @override
  void dispose() {
    if (_userListener != null) {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).removeListener(_userListener!);
    }
    super.dispose();
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
                onChange: (query) {
                  // Optional: implement local search within favourites
                  // eventProvider.searchInFavourite(query);
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (_, index) =>
                    EventItem(event: eventProvider.favouriteEvents[index]),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: eventProvider.favouriteEvents.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
