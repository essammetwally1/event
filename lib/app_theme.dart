import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF5669FF);
  static const Color gray = Color(0xFF7B7B7B);
  static const Color backgroundWhite = Color(0xFFF2FEFF);
  static const Color black = Color(0xFF1C1C1C);
  static const Color red = Color(0xFFFF5659);

  static ThemeData lightTheme = ThemeData(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: backgroundWhite,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: primary,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: backgroundWhite,
      unselectedItemColor: backgroundWhite,
    ),
    bottomAppBarTheme: BottomAppBarTheme(color: primary, elevation: 0),
  );
  static ThemeData dartTheme = ThemeData();
}
