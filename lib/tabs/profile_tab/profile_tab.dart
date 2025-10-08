import 'package:event/components/profile_avatar.dart';
import 'package:event/shared/app_theme.dart';
import 'package:event/models/user_model.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/tabs/profile_tab/dropdown_section.dart';
import 'package:event/tabs/profile_tab/profile_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.currentUser;
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: user != null ? ProfileDrawer(userModel: user) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
              bottom: 16,
              left: 20,
              right: 16,
              top: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.85),

                  AppTheme.primary.withValues(alpha: 0.9),
                  AppTheme.primary.withValues(alpha: 0.9),
                  AppTheme.primary.withValues(alpha: 0.9),
                  AppTheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.bottomRight,
              ),
              color: settingsProvider.isDark
                  ? AppTheme.primary.withValues(alpha: 0.5)
                  : AppTheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
              ),
            ),
            child: SafeArea(
              child: userProvider.currentUser != null
                  ? Row(
                      children: [
                        ProfileAvatar(radius: 32, imageUrl: user!.imageUrl),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user!.name,
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
                        InkWell(
                          onTap: () {
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: AppTheme.backgroundWhite,
                            foregroundColor: AppTheme.red,
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: SvgPicture.asset(
                                'assets/icons/settings.svg',
                                colorFilter: const ColorFilter.mode(
                                  AppTheme.red,
                                  BlendMode.srcIn,
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.backgroundWhite,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        const Spacer(),
                        _buildLogoutButton(
                          context,
                          null,
                          textTheme, // Pass textTheme here
                        ),
                      ],
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
            child: DropdownSection(),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

Widget _buildLogoutButton(
  BuildContext context,
  UserProvider? userProvider,
  TextTheme textTheme, // Add textTheme parameter
) {
  return InkWell(
    onTap: () {
      Scaffold.of(context).openEndDrawer();
    },
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
