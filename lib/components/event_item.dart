import 'package:event/models/event_model.dart';
import 'package:event/provider/event_provider.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/screens/event_item_screen.dart';
import 'package:event/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventItem extends StatelessWidget {
  final EventModel event;
  const EventItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).isDark;
    final userProvider = Provider.of<UserProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final isLoved = userProvider.isFavourite(event.id);

    final Size screenSize = MediaQuery.sizeOf(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventItemScreen(eventModel: event),
            ),
          );
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/categoreis/${event.categoryModel.imageName}.png',
                height: screenSize.height * .35,
                width: screenSize.width,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.backgroundDark
                    : AppTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    event.dateTime.day.toString(),
                    style: textTheme.titleLarge!.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(event.dateTime).toUpperCase(),
                    style: textTheme.titleLarge!.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.backgroundDark
                      : AppTheme.backgroundWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.description,
                            style: textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.backgroundWhite
                                  : AppTheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        isLoved
                            ? Icons.favorite_sharp
                            : Icons.favorite_outline_outlined,
                        color: AppTheme.primary,
                        size: 30,
                      ),
                      onPressed: () {
                        if (isLoved) {
                          userProvider.removeEventFromFavourite(event.id);
                        } else {
                          userProvider.addEventToFavourite(event.id);
                        }
                        // keep LoveTab in sync immediately (also covered by the listener we added)
                        final favIds =
                            userProvider.currentUser?.favouriteEventsIds ??
                            const <String>[];
                        eventProvider.filterFavouriteEvents(favIds);
                      },
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
}
