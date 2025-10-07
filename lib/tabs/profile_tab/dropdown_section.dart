import 'package:event/shared/app_theme.dart';
import 'package:event/tabs/profile_tab/language_model.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DropdownSection extends StatefulWidget {
  const DropdownSection({super.key});

  @override
  State<DropdownSection> createState() => _DropdownSectionState();
}

class _DropdownSectionState extends State<DropdownSection> {
  final List<Language> languages = [
    Language(code: 'en', name: 'English'),
    Language(code: 'ar', name: 'العربية'),
  ];
  String menuValue = 'en';
  bool isActiveSwitch = true;
  late bool isDark;

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);
    isDark = settingsProvider.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Dark Theme',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: isDark ? AppTheme.backgroundWhite : AppTheme.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Switch(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.backgroundWhite,
              value: isDark,
              onChanged: (value) {
                settingsProvider.changeTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ],
        ),

        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Language',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: isDark ? AppTheme.backgroundWhite : AppTheme.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Container(
              width: MediaQuery.sizeOf(context).width * .4,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: BoxBorder.all(color: AppTheme.primary),
              ),
              child: DropdownButton(
                value: menuValue,
                borderRadius: BorderRadius.circular(16),

                dropdownColor: isDark
                    ? AppTheme.backgroundDark
                    : AppTheme.backgroundWhite,

                iconEnabledColor: AppTheme.primary,

                isExpanded: true,
                underline: SizedBox(),
                iconSize: 30,
                items: languages
                    .map(
                      (element) => DropdownMenuItem(
                        value: element.code,
                        child: Row(
                          children: [
                            Text(
                              element.name,
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (menuValue != value) {
                    setState(() {
                      menuValue = value!;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
