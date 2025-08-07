import 'package:event/app_theme.dart';
import 'package:event/auth/login_screen.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/profile_tab/dropdown_section.dart';
import 'package:event/profile_tab/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileTab extends StatelessWidget {
  static const String routeName = '/profile';

  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(textTheme: textTheme),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
            child: DropdownSection(),
          ),
          Spacer(),

          InkWell(
            onTap: () async {
              FirebaseService.signOut();
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 50),
              decoration: BoxDecoration(
                color: AppTheme.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/logout.svg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(width: 8),
                  Text('Logout', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
