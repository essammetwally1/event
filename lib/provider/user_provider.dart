import 'package:event/firebase/firebase_service.dart';
import 'package:event/models/user_model.dart';
import 'package:event/shared/user_storage_service.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel? currentUser;

  void updateCurrentUser(UserModel? user) {
    currentUser = user;
    notifyListeners();
  }

  // Auto-login using stored user ID
  Future<bool> autoLogin() async {
    try {
      final storedUserId = await UserStorageService.getStoredUserId();

      if (storedUserId == null) return false;

      // Get user data from Firebase using the stored user ID
      final usersCollection = FirebaseService.getUsersCollection();
      final docSnapshot = await usersCollection.doc(storedUserId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        currentUser = docSnapshot.data()!;
        notifyListeners();
        return true;
      } else {
        // User doesn't exist in Firestore, clear credentials
        await UserStorageService.clearUserCredentials();
        return false;
      }
    } catch (error) {
      print('Auto-login failed: $error');
      await UserStorageService.clearUserCredentials();
      return false;
    }
  }

  bool isFavourite(String eventId) {
    return currentUser?.favouriteEventsIds.contains(eventId) ?? false;
  }

  void addEventToFavourite(String eventId) {
    if (currentUser == null) return;

    FirebaseService.addEventToFavourite(eventId);
    currentUser!.favouriteEventsIds.add(eventId);
    notifyListeners();
  }

  void removeEventToFavourite(String eventId) {
    if (currentUser == null) return;

    FirebaseService.removeEventFromFavourite(eventId);
    currentUser!.favouriteEventsIds.remove(eventId);
    notifyListeners();
  }

  // Clear user data on logout
  void clearUser() {
    currentUser = null;
    notifyListeners();
  }
}
