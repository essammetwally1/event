import 'package:event/app_theme.dart';
import 'package:event/components/navbar_icon.dart';
import 'package:event/tabs/home_tab/home_tab.dart';
import 'package:event/tabs/love_tab/love_tab.dart';
import 'package:event/tabs/map_tap/map_tab.dart';
import 'package:event/tabs/profile_tab/profile_tab.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/screens/create_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  static const List<Widget> taps = <Widget>[
    HomeTab(),
    MapTab(),
    LoveTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: taps[selectedIndex],
      floatingActionButton: FloatingActionButton(
        shape: Provider.of<SettingsProvider>(context).isDark
            ? CircleBorder(
                side: BorderSide(color: AppTheme.backgroundWhite, width: 4),
              )
            : null,
        onPressed: () {
          Navigator.of(
            context,
          ).pushReplacementNamed(CreateEventScreen.routeName);
        },
        child: Icon(Icons.add, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        shape: CircularNotchedRectangle(),

        notchMargin: 8,
        clipBehavior: Clip.antiAlias,

        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            if (index != selectedIndex) {
              setState(() {
                selectedIndex = index;
              });
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: NavbarIcon(iconName: 'home'),
              activeIcon: NavbarIcon(iconName: 'homeActive'),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: NavbarIcon(iconName: 'location'),
              activeIcon: NavbarIcon(iconName: 'locationActive'),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: NavbarIcon(iconName: 'like'),
              activeIcon: NavbarIcon(iconName: 'likeActive'),
              label: 'Love',
            ),
            BottomNavigationBarItem(
              icon: NavbarIcon(iconName: 'profile'),
              activeIcon: NavbarIcon(iconName: 'profileActive'),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
