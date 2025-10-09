import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const _kThemeKey = 'theme_mode';
  late SharedPreferences prefs;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  SettingsProvider() {
    _loadTheme(); // async fire-and-forget; notifies when loaded
  }

  Future<void> _loadTheme() async {
    prefs = await SharedPreferences.getInstance();
    final String? appTheme = prefs.getString(_kThemeKey);
    switch (appTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  Future<void> changeTheme(ThemeMode theme) async {
    _themeMode = theme;
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, _encode(theme));
    notifyListeners();
  }

  Future<void> useSystemTheme() => changeTheme(ThemeMode.system);

  String _encode(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
