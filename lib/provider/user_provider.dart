import 'package:event/services/firebase_service.dart';
import 'package:event/models/user_model.dart';
import 'package:event/services/subabase_service.dart';
import 'package:event/services/user_storage_service.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get hasProfileImage => _currentUser?.imageUrl?.isNotEmpty ?? false;

  void updateCurrentUser(UserModel? user) {
    _currentUser = user;
    _error = null;
    notifyListeners();
    ();
  }

  Future<bool> autoLogin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    ();

    try {
      final storedUserId = await UserStorageService.getStoredUserId();
      if (storedUserId == null) {
        _isLoading = false;
        notifyListeners();
        ();
        return false;
      }

      final user = await FirebaseService.getUserById(storedUserId);
      if (user != null) {
        // Get Supabase image URL if available
        String? supabaseImageUrl;
        try {
          final imageExists = await SupabaseService.exists(user.id);
          if (imageExists) {
            supabaseImageUrl = SupabaseService.publicUrl(user.id);
          }
        } catch (e) {
          // Supabase check failed, use existing image URL
        }

        // Use Supabase image URL if available, otherwise use existing one
        final updatedUser = UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          imageUrl: supabaseImageUrl ?? user.imageUrl,
          favouriteEventsIds: user.favouriteEventsIds,
        );

        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
        ();
        return true;
      } else {
        await UserStorageService.clearUserCredentials();
        _isLoading = false;
        notifyListeners();
        ();
        return false;
      }
    } catch (error) {
      await UserStorageService.clearUserCredentials();
      _isLoading = false;
      notifyListeners();
      ();
      return false;
    }
  }

  Future<void> updateUserProfileImage(String imagePath) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();
    ();

    try {
      final imageUrl = await FirebaseService.uploadUserImage(
        userId: _currentUser!.id,
        imagePath: imagePath,
      );

      if (imageUrl != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          imageUrl: imageUrl,
          favouriteEventsIds: _currentUser!.favouriteEventsIds,
        );
      }
    } catch (e) {
      _error = 'Error updating profile image';
    } finally {
      _isLoading = false;
      notifyListeners();
      ();
    }
  }

  bool isFavourite(String eventId) {
    return _currentUser?.favouriteEventsIds.contains(eventId) ?? false;
  }

  void addEventToFavourite(String eventId) {
    if (_currentUser == null) return;

    FirebaseService.addEventToFavourite(eventId);
    _currentUser = UserModel(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      imageUrl: _currentUser!.imageUrl,
      favouriteEventsIds: [..._currentUser!.favouriteEventsIds, eventId],
    );
    notifyListeners();
    ();
  }

  void removeEventFromFavourite(String eventId) {
    if (_currentUser == null) return;

    FirebaseService.removeEventFromFavourite(eventId);
    _currentUser = UserModel(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      imageUrl: _currentUser!.imageUrl,
      favouriteEventsIds: _currentUser!.favouriteEventsIds
          .where((id) => id != eventId)
          .toList(),
    );
    notifyListeners();
    ();
  }

  void clearUser() {
    _currentUser = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
    ();
  }

  void clearError() {
    _error = null;
    notifyListeners();
    ();
  }

  Future<void> deleteProfileImage() async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call Supabase to delete the image
      final success = await SupabaseService.delete(_currentUser!.id);

      if (success) {
        // Update local user model to remove image URL
        _currentUser = UserModel(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          imageUrl: null,
          favouriteEventsIds: _currentUser!.favouriteEventsIds,
        );
        _error = null;
      } else {
        _error = 'Failed to delete profile image';
      }
    } catch (e) {
      _error = 'Error deleting profile image: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
