import 'package:event/app_theme.dart';
import 'package:event/auth/login_screen.dart';
import 'package:event/auth/register_scree.dart';
import 'package:event/screens/create_event_screen.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/screens/onboarding_screen.dart';
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
      initialRoute: OnboardingScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        CreateEventScreen.routeName: (context) => CreateEventScreen(),
        OnboardingScreen.routeName: (context) => OnboardingScreen(),
      },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.dartTheme,
      themeMode: ThemeMode.light,
    );
  }
}
