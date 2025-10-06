import 'package:event/app_theme.dart';
import 'package:event/models/user_model.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatelessWidget {
  final TextTheme textTheme;
  const ProfileHeader({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final UserModel? userModel = Provider.of<UserProvider>(context).currentUser;
    final bool isDark = Provider.of<SettingsProvider>(context).isDark;
    return Container(
      padding: EdgeInsets.only(bottom: 16, left: 20, right: 16, top: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primary.withValues(alpha: .5)
            : AppTheme.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(64)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userModel!.name, style: textTheme.headlineSmall),
                SizedBox(height: 10),
                Text(
                  userModel.email,
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
