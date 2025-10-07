import 'package:event/auth/login_screen.dart';
import 'package:event/components/route_loading_indicator.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RootDeciderScreen extends StatefulWidget {
  static const routeName = '/root';
  const RootDeciderScreen({super.key});

  @override
  State<RootDeciderScreen> createState() => _RootDeciderScreenState();
}

class _RootDeciderScreenState extends State<RootDeciderScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final isAutoLoggedIn = await userProvider.autoLogin();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (isAutoLoggedIn) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const RouteLoadingIndicator()
          : const SizedBox.shrink(),
    );
  }
}
