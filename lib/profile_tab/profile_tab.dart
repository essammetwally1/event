import 'package:event/profile_tab/dropdown_section.dart';
import 'package:event/profile_tab/profile_header.dart';
import 'package:flutter/material.dart';

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
        ],
      ),
    );
  }
}
