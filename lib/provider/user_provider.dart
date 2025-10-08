import 'package:event/services/firebase_service.dart';
import 'package:event/models/user_model.dart';
import 'package:event/services/subabase_service.dart';
import 'package:event/services/user_storage_service.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isNotifying = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get hasProfileImage => _currentUser?.imageUrl?.isNotEmpty ?? false;

  void updateCurrentUser(UserModel? user) {
    _currentUser = user;
    _error = null;
    _scheduleNotifyListeners();
  }

  Future<bool> autoLogin() async {
    _isLoading = true;
    _error = null;
    _scheduleNotifyListeners();

    try {
      final storedUserId = await UserStorageService.getStoredUserId();
      if (storedUserId == null) {
        _isLoading = false;
        _scheduleNotifyListeners();
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
        _scheduleNotifyListeners();
        return true;
      } else {
        await UserStorageService.clearUserCredentials();
        _isLoading = false;
        _scheduleNotifyListeners();
        return false;
      }
    } catch (error) {
      await UserStorageService.clearUserCredentials();
      _isLoading = false;
      _scheduleNotifyListeners();
      return false;
    }
  }

  Future<void> updateUserProfileImage(String imagePath) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    _scheduleNotifyListeners();

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
      _scheduleNotifyListeners();
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
    _scheduleNotifyListeners();
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
    _scheduleNotifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _error = null;
    _isLoading = false;
    _scheduleNotifyListeners();
  }

  void clearError() {
    _error = null;
    _scheduleNotifyListeners();
  }

  void _scheduleNotifyListeners() {
    if (_isNotifying) return;
    _isNotifying = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isNotifying = false;
      if (hasListeners) {
        notifyListeners();
      }
    });
  }
}
