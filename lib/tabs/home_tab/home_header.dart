import 'package:event/app_theme.dart';
import 'package:event/tabs/home_tab/tab_item.dart';
import 'package:event/models/category_model.dart';
import 'package:event/provider/event_provider.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  int currentIndex = 0;
  late bool isDark;
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    isDark = Provider.of<SettingsProvider>(context).isDark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primary.withValues(alpha: .5)
            : AppTheme.primary,
        borderRadius: BorderRadius.only(
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

            SizedBox(height: 8),

            DefaultTabController(
              length: CategoryModel.categoryList.length + 1,

              child: TabBar(
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                isScrollable: true,
                labelPadding: EdgeInsetsDirectional.only(end: 10),
                onTap: (index) {
                  if (currentIndex == index) return;

                  currentIndex = index;
                  CategoryModel? categoryModel = currentIndex == 0
                      ? null
                      : CategoryModel.categoryList[currentIndex - 1];
                  Provider.of<EventProvider>(
                    context,
                    listen: false,
                  ).filterEvents(categoryModel);
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
