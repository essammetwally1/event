import 'package:event/shared/app_theme.dart';
import 'package:event/auth/login_screen.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/models/user_model.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/shared/user_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(64),
          bottomRight: Radius.circular(64),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.backgroundWhite,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primary,
                  child: SvgPicture.asset(
                    'assets/icons/addprofile.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
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
            ),
            InkWell(
              onTap: () async {
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: AppTheme.backgroundWhite,
                      title: Text(
                        'Confirm Logout',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: AppTheme.primary,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to log out?',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(color: AppTheme.black),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Return false when user cancels
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(color: AppTheme.primary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Return true when user confirms
                            UserStorageService.clearUserCredentials();
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            'Logout',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(color: AppTheme.red),
                          ),
                        ),
                      ],
                    );
                  },
                );

                // If user confirmed logout (true), proceed with logout
                if (shouldLogout == true) {
                  await FirebaseService.signOut();
                  Navigator.pushReplacementNamed(
                    context,
                    LoginScreen.routeName,
                  ).then((_) {
                    Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).updateCurrentUser(null);
                  });
                }
                // If user canceled (false or null), do nothing
              },
              child: Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppTheme.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/logout.svg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppTheme.backgroundWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
