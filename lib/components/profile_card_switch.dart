import 'package:event/provider/settings_provider.dart';
import 'package:event/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileCardSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ProfileCardSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: isDark
                        ? AppTheme.backgroundWhite
                        : AppTheme.backgroundDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: settingsProvider.isUsingSystemTheme ? null : onChanged,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
