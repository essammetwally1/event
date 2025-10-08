import 'package:event/auth/login_screen.dart';
import 'package:event/auth/register_screen.dart';
import 'package:event/provider/event_provider.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/screens/create_event_screen.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/screens/onboarding_screen.dart';
import 'package:event/screens/root_decider_screen.dart';
import 'package:event/shared/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://gaxkwtyozcmccafihhif.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdheGt3dHlvemNtY2NhZmloaGlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4ODA4NjYsImV4cCI6MjA3NTQ1Njg2Nn0.w_tSdfw61bOnuyN5Sce0qsXT5tcswzZ9r15tuJcOd7I',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider()..getEvents()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: EventApp(),
    ),
  );
}

class EventApp extends StatelessWidget {
  const EventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RootDeciderScreen.routeName,
      routes: {
        RootDeciderScreen.routeName: (context) => RootDeciderScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        CreateEventScreen.routeName: (context) => CreateEventScreen(),
        OnboardingScreen.routeName: (context) => OnboardingScreen(),
      },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.dartTheme,
      themeMode: Provider.of<SettingsProvider>(context).themeMode,
    );
  }
}
