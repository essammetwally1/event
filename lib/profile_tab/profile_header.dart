import 'package:event/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final TextTheme textTheme;
  const ProfileHeader({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(64)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Image.asset(
              'assets/routeLogo.png',
              height: 124,
              width: 124,
              fit: BoxFit.fill,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User Name', style: textTheme.headlineSmall),
                SizedBox(height: 10),
                Text(
                  'UserEmail@gmail.com',
                  style: textTheme.titleMedium!.copyWith(
                    color: AppTheme.backgroundWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
