import 'package:cached_network_image/cached_network_image.dart';
import 'package:event/services/image_picker_service.dart';
import 'package:event/shared/app_theme.dart';
import 'package:event/auth/login_screen.dart';
import 'package:event/services/firebase_service.dart';
import 'package:event/models/user_model.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/services/user_storage_service.dart';
import 'package:event/shared/utilis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatelessWidget {
  final TextTheme textTheme;
  const ProfileHeader({super.key, required this.textTheme});
  Future<void> _handleImagePick(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    try {
      final imageFile = await ImagePickerService.pickAndCropImage(context);
      if (imageFile != null) {
        await userProvider.updateUserProfileImage(imageFile.path);

        Utils.showSuccessMessage('Profile image updated successfully!');
      }
    } catch (e) {
      Utils.showErrorMessage('Failed to update image: ${e.toString()}');
    }
  }

  Future<void> _handleLogout(
    BuildContext context,
    UserProvider? userProvider,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierColor: AppTheme.primary.withValues(alpha: 0.3),
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundWhite,
        title: Text(
          'Confirm Logout',
          style: textTheme.titleLarge!.copyWith(color: AppTheme.primary),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: textTheme.titleMedium!.copyWith(color: AppTheme.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: textTheme.titleMedium!.copyWith(color: AppTheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Logout',
              style: textTheme.titleMedium!.copyWith(color: AppTheme.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _performLogout(context, userProvider);
    }
  }

  Future<void> _performLogout(
    BuildContext context,
    UserProvider? userProvider,
  ) async {
    try {
      await UserStorageService.clearUserCredentials();
      await FirebaseService.signOut();
      userProvider?.clearUser();
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    } catch (e) {
      Utils.showErrorMessage('Logout failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );

    return Container(
      padding: const EdgeInsets.only(bottom: 16, left: 20, right: 16, top: 20),
      decoration: BoxDecoration(
        color: settingsProvider.isDark
            ? AppTheme.primary.withValues(alpha: 0.5)
            : AppTheme.primary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50)),
      ),
      child: SafeArea(
        child: userProvider.currentUser != null
            ? _buildUserHeader(context, userProvider, settingsProvider.isDark)
            : _buildLoadingHeader(context, settingsProvider.isDark),
      ),
    );
  }

  Widget _buildUserHeader(
    BuildContext context,
    UserProvider userProvider,
    bool isDark,
  ) {
    final user = userProvider.currentUser!;

    return Row(
      children: [
        _buildProfileAvatar(context, user, userProvider),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: textTheme.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: textTheme.titleMedium!.copyWith(
                  color: AppTheme.backgroundWhite,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _buildLogoutButton(context, userProvider),
      ],
    );
  }

  Widget _buildProfileAvatar(
    BuildContext context,
    UserModel user,
    UserProvider userProvider,
  ) {
    return GestureDetector(
      onTap: () => _handleImagePick(context, userProvider),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: AppTheme.backgroundWhite,
        child: CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: userProvider.hasProfileImage
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) =>
                        const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget: (context, url, error) => _buildDefaultAvatar(),
                  ),
                )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return SvgPicture.asset(
      'assets/icons/addprofile.svg',
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      colorFilter: const ColorFilter.mode(AppTheme.primary, BlendMode.srcIn),
    );
  }

  Widget _buildLogoutButton(BuildContext context, UserProvider? userProvider) {
    return InkWell(
      onTap: () => _handleLogout(context, userProvider),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/logout.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppTheme.backgroundWhite,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: textTheme.titleMedium?.copyWith(
                color: AppTheme.backgroundWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppTheme.backgroundWhite,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        const Spacer(),
        _buildLogoutButton(context, null),
      ],
    );
  }
}
