import 'package:event/firebase/firebase_service.dart';
import 'package:event/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel? currentUser;

  void updateCurrentUser(UserModel? user) {
    currentUser = user;
    notifyListeners();
  }

  bool isFavourite(String eventId) {
    return currentUser!.favouriteEventsIds.contains(eventId);
  }

  void addEventToFavourite(String eventId) {
    FirebaseService.addEventToFavourite(eventId);
    currentUser!.favouriteEventsIds.add(eventId);
    notifyListeners();
  }

  void removeEventToFavourite(String eventId) {
    FirebaseService.removeEventFromFavourite(eventId);
    currentUser!.favouriteEventsIds.remove(eventId);
    notifyListeners();
  }
}
