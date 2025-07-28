import 'package:event/components/navbar_icon.dart';
import 'package:event/home_tab/home_tab.dart';
import 'package:flutter/material.dart';

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
    Center(child: Text('Location Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Favorites Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: taps[selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
