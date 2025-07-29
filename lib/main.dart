import 'package:event/app_theme.dart';
import 'package:event/auth/login_screen.dart';
import 'package:event/auth/register_scree.dart';
import 'package:event/home_screen.dart';
import 'package:event/love_tab/love_tab.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(EventApp());
}

class EventApp extends StatelessWidget {
  const EventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        LoveTab.routeName: (context) => LoveTab(),
      },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.dartTheme,
      themeMode: ThemeMode.light,
    );
  }
}
