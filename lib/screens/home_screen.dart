import 'package:event/shared/app_theme.dart';
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

  // Keep pages’ state (including HomeTab’s header selection)
  final PageStorageBucket _bucket = PageStorageBucket();

  late final List<Widget> _pages = const [
    HomeTab(key: PageStorageKey('homeTab')),
    MapTab(key: PageStorageKey('mapTab')),
    LoveTab(key: PageStorageKey('loveTab')),
    ProfileTab(key: PageStorageKey('profileTab')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          // 👈 preserves tabs
          index: selectedIndex,
          children: _pages,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: Provider.of<SettingsProvider>(context).isDark
            ? const CircleBorder(
                side: BorderSide(color: AppTheme.backgroundWhite, width: 4),
              )
            : null,
        onPressed: () {
          Navigator.of(
            context,
          ).pushReplacementNamed(CreateEventScreen.routeName);
        },
        child: const Icon(Icons.add, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            if (index != selectedIndex) {
              setState(() => selectedIndex = index);
            }
          },
          items: const [
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
