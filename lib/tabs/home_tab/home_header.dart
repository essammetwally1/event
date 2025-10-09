import 'package:event/shared/app_theme.dart';
import 'package:event/tabs/home_tab/tab_item.dart';
import 'package:event/models/category_model.dart';
import 'package:event/provider/event_provider.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatefulWidget {
  final ValueChanged<int>? onCategoryTap;
  const HomeHeader({super.key, required this.onCategoryTap});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  static const String _psId = 'homeHeaderSelectedIndex';

  int currentIndex = 0;
  late bool isDark;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    isDark = Provider.of<SettingsProvider>(context).isDark;

    // Try reading saved index (only first time build runs)
    final saved =
        PageStorage.of(context).readState(context, identifier: _psId) as int? ??
        currentIndex;
    if (currentIndex != saved) currentIndex = saved;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primary.withValues(alpha: .5)
            : AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome Back ✨', style: textTheme.titleSmall),
            Text(
              Provider.of<UserProvider>(context).currentUser!.name,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // Keep your DefaultTabController; just set initialIndex.
            DefaultTabController(
              length: CategoryModel.categoryList.length + 1,
              initialIndex: currentIndex.clamp(
                0,
                CategoryModel.categoryList.length,
              ),
              child: TabBar(
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                isScrollable: true,
                labelPadding: const EdgeInsetsDirectional.only(end: 10),

                onTap: (index) {
                  if (currentIndex == index) {
                    // still notify so list can jump to top on same-tab taps if you want
                    widget.onCategoryTap?.call(index);
                    return;
                  }

                  currentIndex = index;

                  // Filter your events based on selected category
                  final CategoryModel? categoryModel = currentIndex == 0
                      ? null
                      : CategoryModel.categoryList[currentIndex - 1];

                  Provider.of<EventProvider>(
                    context,
                    listen: false,
                  ).filterEvents(categoryModel);

                  // Persist the chosen tab
                  PageStorage.of(
                    context,
                  ).writeState(context, currentIndex, identifier: _psId);

                  // Notify parent (HomeTab) to scroll the list up
                  widget.onCategoryTap?.call(index);

                  setState(() {});
                },

                tabs: [
                  TabItem(
                    label: 'All',
                    icon: Icons.safety_check,
                    isSelected: currentIndex == 0,
                    selectedBackgroundColor: isDark
                        ? AppTheme.primary
                        : AppTheme.backgroundWhite,
                    unSelectedBackgroundColor: isDark
                        ? AppTheme.backgroundDark
                        : AppTheme.primary,
                    foreginSelectedColor: isDark
                        ? AppTheme.backgroundWhite
                        : AppTheme.primary,
                    foreginUnSelectedColor: AppTheme.backgroundWhite,
                  ),
                  ...CategoryModel.categoryList.map(
                    (category) => TabItem(
                      label: category.label,
                      icon: category.icon,
                      isSelected:
                          currentIndex ==
                          CategoryModel.categoryList.indexOf(category) + 1,
                      selectedBackgroundColor: isDark
                          ? AppTheme.primary
                          : AppTheme.backgroundWhite,
                      unSelectedBackgroundColor: isDark
                          ? AppTheme.backgroundDark
                          : AppTheme.primary,
                      foreginSelectedColor: isDark
                          ? AppTheme.backgroundWhite
                          : AppTheme.primary,
                      foreginUnSelectedColor: AppTheme.backgroundWhite,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
