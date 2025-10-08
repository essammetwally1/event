import 'package:shared_preferences/shared_preferences.dart';

class UserStorageService {
  static const String _rememberMeKey = 'remember_me';
  static const String _userIdKey = 'user_id';

  // Save only user ID if remember me is enabled
  static Future<void> saveUserCredentials({
    required String userId,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (rememberMe) {
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_userIdKey, userId);
    } else {
      await clearUserCredentials();
    }
  }

  // Get stored user ID
  static Future<String?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

    if (!rememberMe) return null;

    return prefs.getString(_userIdKey);
  }

  // Clear user credentials (on logout)
  static Future<void> clearUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, false);
    await prefs.remove(_userIdKey);
  }

  // Check if remember me is enabled
  static Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }
}
