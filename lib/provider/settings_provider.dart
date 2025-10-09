import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const _kThemeKey = 'theme_mode';
  late SharedPreferences prefs;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // Proper system theme detection
  bool get isDark {
    if (_themeMode == ThemeMode.system) {
      // This should be called in build context where MediaQuery is available
      // Or use WidgetsBinding.instance.window.platformBrightness
      return WidgetsBinding.instance.window.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // Track if we're using system theme
  bool get isUsingSystemTheme => _themeMode == ThemeMode.system;

  SettingsProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    prefs = await SharedPreferences.getInstance();
    final String? savedTheme = prefs.getString(_kThemeKey);

    // Default to system theme if nothing saved
    _themeMode = _decode(savedTheme) ?? ThemeMode.system;
    notifyListeners();
  }

  Future<void> changeTheme(ThemeMode theme) async {
    _themeMode = theme;
    await prefs.setString(_kThemeKey, _encode(theme));
    notifyListeners();
  }

  Future<void> useSystemTheme() async {
    await changeTheme(ThemeMode.system);
  }

  // Reset to system theme and clear preference
  Future<void> resetToSystem() async {
    _themeMode = ThemeMode.system;
    await prefs.remove(_kThemeKey); // Remove saved preference
    notifyListeners();
  }

  String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode? _decode(String? mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
}
