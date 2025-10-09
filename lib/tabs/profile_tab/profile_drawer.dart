import 'package:event/auth/login_screen.dart';
import 'package:event/components/profile_avatar.dart';
import 'package:event/components/profile_card.dart';
import 'package:event/components/profile_card_switch.dart';
import 'package:event/components/reset_password_sheet.dart';
import 'package:event/components/update_name_sheet.dart';
import 'package:event/models/user_model.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/services/firebase_service.dart';
import 'package:event/services/image_picker_service.dart';
import 'package:event/services/user_storage_service.dart';
import 'package:event/shared/app_theme.dart';
import 'package:event/shared/utilis.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileDrawer extends StatefulWidget {
  final UserModel userModel;

  const ProfileDrawer({super.key, required this.userModel});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  int? _expandedIndex;
  bool isActiveSwitch = true;
  late bool isDark;

  Future<void> _handleLogout(
    BuildContext context,
    UserProvider? userProvider,
    TextTheme textTheme,
    bool isDark,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierColor: AppTheme.primary.withValues(alpha: 0.3),
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppTheme.backgroundDark
            : AppTheme.backgroundWhite,
        title: Text(
          'Confirm Logout',
          style: textTheme.titleLarge!.copyWith(color: AppTheme.primary),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: textTheme.titleMedium!.copyWith(
            color: isDark ? AppTheme.backgroundWhite : AppTheme.black,
          ),
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

  void _openProfilePanel(
    BuildContext context, {
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundWhite,
      barrierColor: AppTheme.primary.withValues(alpha: 0.1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.primary : AppTheme.primary),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppTheme.backgroundWhite
                                      : AppTheme.primary,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: isDark
                                ? AppTheme.backgroundWhite
                                : AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: SingleChildScrollView(child: child),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final userProvider = Provider.of<UserProvider>(context);
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );
    final isDark = settingsProvider.isDark;

    return Drawer(
      width: (size.width * 0.8).clamp(300, 520),
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final double headerH = (w * 0.45).clamp(180, 240);
              final double avatarR = (w * 0.12).clamp(36, 56);
              final double spacing = (w * 0.03).clamp(8, 16);

              return Container(
                width: double.infinity,
                height: headerH,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.primary.withValues(alpha: 0.5)
                      : AppTheme.primary,
                  gradient: isDark
                      ? null
                      : LinearGradient(
                          colors: [
                            AppTheme.primary,
                            AppTheme.primary.withValues(alpha: 0.85),
                            AppTheme.primary.withValues(alpha: 0.9),
                            AppTheme.primary.withValues(alpha: 0.9),
                            AppTheme.primary.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing,
                      vertical: spacing,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _handleImagePick(context, userProvider),
                          child: Stack(
                            children: [
                              ProfileAvatar(
                                radius: avatarR,
                                imageUrl: widget.userModel.imageUrl,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 5,
                                child: widget.userModel.imageUrl != null
                                    ? Icon(
                                        Icons.add_a_photo_rounded,
                                        color: AppTheme.backgroundWhite,
                                      )
                                    : SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: spacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.userModel.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.userModel.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ===== Menu Items =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildExpandableDrawerItem(
                  context,
                  index: 0,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {},
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 380;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            [
                              ProfileCard(
                                icon: Icons.edit_outlined,
                                title: 'Update Name',
                                subtitle: 'Change your display name',
                                isDark: isDark,
                                onTap: () {
                                  _openProfilePanel(
                                    context,
                                    title: 'Update Name',
                                    child: const UpdateNameSheet(),
                                    isDark: isDark,
                                  );
                                },
                              ),
                              ProfileCard(
                                icon: Icons.lock_reset_outlined,
                                title: 'Reset Password',
                                subtitle: 'Change your account password',
                                isDark: isDark,
                                onTap: () {
                                  _openProfilePanel(
                                    context,
                                    title: 'Reset Password',
                                    child: const ResetPasswordSheet(),
                                    isDark: isDark,
                                  );
                                },
                              ),
                            ].map((w) {
                              return SizedBox(
                                width: isNarrow
                                    ? double.infinity
                                    : (constraints.maxWidth - 12) / 2,
                                child: w,
                              );
                            }).toList(),
                      );
                    },
                  ),

                  isDark: isDark,
                ),

                _buildExpandableDrawerItem(
                  context,
                  index: 1,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {},
                  isDark: isDark,
                  child: Column(
                    children: [
                      // Theme Selection Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.backgroundDark
                              : AppTheme.backgroundWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appearance',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),

                            // System Theme Option
                            ListTile(
                              leading: Icon(
                                Icons.smartphone,
                                color: settingsProvider.isUsingSystemTheme
                                    ? AppTheme.primary
                                    : Colors.grey,
                              ),
                              title: Text(
                                'Use device theme',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      color: isDark
                                          ? AppTheme.backgroundWhite
                                          : AppTheme.backgroundDark,
                                    ),
                              ),
                              trailing: settingsProvider.isUsingSystemTheme
                                  ? Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primary,
                                    )
                                  : null,
                              onTap: () => settingsProvider.useSystemTheme(),
                              contentPadding: EdgeInsets.zero,
                            ),

                            // Light Theme Option
                            ListTile(
                              leading: Icon(
                                Icons.light_mode,
                                color:
                                    settingsProvider.themeMode ==
                                        ThemeMode.light
                                    ? AppTheme.primary
                                    : Colors.grey,
                              ),
                              title: Text(
                                'Light mode',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      color: isDark
                                          ? AppTheme.backgroundWhite
                                          : AppTheme.backgroundDark,
                                    ),
                              ),
                              trailing:
                                  settingsProvider.themeMode == ThemeMode.light
                                  ? Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primary,
                                    )
                                  : null,
                              onTap: () =>
                                  settingsProvider.changeTheme(ThemeMode.light),
                              contentPadding: EdgeInsets.zero,
                            ),

                            // Dark Theme Option
                            ListTile(
                              leading: Icon(
                                Icons.dark_mode,
                                color:
                                    settingsProvider.themeMode == ThemeMode.dark
                                    ? AppTheme.primary
                                    : Colors.grey,
                              ),
                              title: Text(
                                'Dark mode',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      color: isDark
                                          ? AppTheme.backgroundWhite
                                          : AppTheme.backgroundDark,
                                    ),
                              ),
                              trailing:
                                  settingsProvider.themeMode == ThemeMode.dark
                                  ? Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primary,
                                    )
                                  : null,
                              onTap: () =>
                                  settingsProvider.changeTheme(ThemeMode.dark),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Quick Toggle Switch (for convenience)
                      ProfileCardSwitch(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Theme',
                        subtitle: settingsProvider.isUsingSystemTheme
                            ? 'Following device theme'
                            : 'Manual theme selection',
                        isDark: isDark,
                        value:
                            isDark, // This shows current appearance (even if system)
                        onChanged: settingsProvider.isUsingSystemTheme
                            ? null // Disable when using system theme
                            : (value) {
                                settingsProvider.changeTheme(
                                  value ? ThemeMode.dark : ThemeMode.light,
                                );
                              },
                      ),
                    ],
                  ),
                ),
                _buildExpandableDrawerItem(
                  context,
                  index: 2,
                  icon: Icons.help_outline,
                  onTap: () {},
                  title: 'Help & Support',
                  isDark: isDark,
                  child: Column(
                    children: [
                      ProfileCard(
                        icon: Icons.article_outlined,
                        title: 'FAQ',
                        subtitle: 'Common questions and quick answers',
                        isDark: isDark,
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      ProfileCard(
                        icon: Icons.support_agent_outlined,
                        title: 'Contact Support',
                        subtitle: 'Get help from our team',
                        isDark: isDark,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                _buildExpandableDrawerItem(
                  context,
                  index: 3,
                  icon: Icons.info_outline,
                  onTap: () {},
                  title: 'About',
                  isDark: isDark,
                  child: Column(
                    children: [
                      ProfileCard(
                        icon: Icons.person_outline,
                        title: 'Developer',
                        subtitle: 'EssamTech',
                        isDark: isDark,
                        onTap: () {
                          // Optional: show more bio
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileCard(
                        icon: Icons.mail_outline,
                        title: 'Email',
                        subtitle: 'essammetwally11@gmail.com',
                        isDark: isDark,
                        onTap: () {
                          // TODO: launch mailto:essammetwally11@gmail.com
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileCard(
                        icon: Icons.verified_outlined,
                        title: 'Version',
                        subtitle: '1.0.0',
                        isDark: isDark,
                        onTap: () {
                          // Optional: show changelog
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: AppTheme.red, size: 24),
                  title: Text(
                    'Logout',
                    style: textTheme.titleMedium!.copyWith(
                      color: isDark ? AppTheme.backgroundWhite : AppTheme.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () =>
                      _handleLogout(context, userProvider, textTheme, isDark),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minLeadingWidth: 28,
                ),
              ],
            ),
          ),

          // ===== Footer =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Event@EssamTeck',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==== Expandable Item Builder ====
  Widget _buildExpandableDrawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Widget child,
    required bool isDark,
  }) {
    final bool isExpanded = _expandedIndex == index;
    final Color color = isExpanded ? AppTheme.primary : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isExpanded
            ? AppTheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: color, size: 24),
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: isDark ? AppTheme.backgroundWhite : AppTheme.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: color,
            ),
            onTap: () {
              setState(() {
                _expandedIndex = _expandedIndex == index ? null : index;
              });
              onTap();
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            minLeadingWidth: 28,
          ),
          if (isExpanded)
            Container(
              margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  width: 3,
                ),
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}
