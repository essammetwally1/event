import 'package:event/auth/login_screen.dart';
import 'package:event/components/route_loading_indicator.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/services/subabase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RootDeciderScreen extends StatefulWidget {
  static const routeName = '/root';
  const RootDeciderScreen({super.key});

  @override
  State<RootDeciderScreen> createState() => _RootDeciderScreenState();
}

class _RootDeciderScreenState extends State<RootDeciderScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await SupabaseService.checkBucketAccess();
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      await _checkAuthentication();
    }
  }

  Future<void> _checkAuthentication() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isAutoLoggedIn = await userProvider.autoLogin();

      if (isAutoLoggedIn) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
    } catch (e) {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const RouteLoadingIndicator(),
    );
  }
}
