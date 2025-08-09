import 'package:event/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel? currentUser;

  void updateCurrentUder(UserModel user) {
    currentUser = user;
    notifyListeners();
  }
}
