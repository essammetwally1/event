import 'package:event/firebase/firebase_service.dart';
import 'package:event/models/category_model.dart';
import 'package:event/models/event_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EventProvider with ChangeNotifier {
  List<EventModel> filteredEvents = [];
  List<EventModel> allEvents = [];
  List<EventModel> favouriteEvents = [];

  Future<void> getEvents() async {
    allEvents = await FirebaseService.getEvents();
    filteredEvents = allEvents;
    notifyListeners();
  }

  void filterEvents(CategoryModel? categoryModel) {
    categoryModel == null
        ? filteredEvents = allEvents
        : filteredEvents = allEvents
              .where((event) => event.categoryModel == categoryModel)
              .toList();
    notifyListeners();
  }

  void filterFavouriteEvents(List<String> favouriteIds) {
    favouriteEvents = allEvents
        .where((event) => favouriteIds.contains(event.id))
        .toList();
    notifyListeners();
  }
}
