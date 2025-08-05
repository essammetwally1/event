import 'package:event/app_theme.dart';
import 'package:event/home_tab/tab_item.dart';
import 'package:event/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeHeader extends StatefulWidget {
  final void Function(CategoryModel?) filterEvents;
  const HomeHeader({super.key, required this.filterEvents});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
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
            Text('User Name', style: textTheme.headlineSmall),
            SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/locationActive.svg'),
                Text('Cairo , Egypt', style: textTheme.titleSmall),
              ],
            ),
            SizedBox(height: 8),

            DefaultTabController(
              length: CategoryModel.categoryList.length + 1,

              child: TabBar(
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                isScrollable: true,
                labelPadding: EdgeInsets.only(right: 10),
                onTap: (index) {
                  if (currentIndex == index) return;

                  currentIndex = index;
                  CategoryModel? categoryModel = currentIndex == 0
                      ? null
                      : CategoryModel.categoryList[currentIndex - 1];
                  widget.filterEvents(categoryModel);
                  setState(() {});
                },
                tabs: [
                  TabItem(
                    label: 'All',
                    icon: Icons.safety_check,
                    isSelected: currentIndex == 0,
                    selectedBackgroundColor: AppTheme.backgroundWhite,
                    unSelectedBackgroundColor: AppTheme.primary,
                    foreginSelectedColor: AppTheme.primary,
                    foreginUnSelectedColor: AppTheme.backgroundWhite,
                  ),
                  ...CategoryModel.categoryList.map(
                    (category) => TabItem(
                      label: category.label,
                      icon: category.icon,
                      isSelected:
                          currentIndex ==
                          CategoryModel.categoryList.indexOf(category) + 1,
                      selectedBackgroundColor: AppTheme.backgroundWhite,
                      unSelectedBackgroundColor: AppTheme.primary,
                      foreginSelectedColor: AppTheme.primary,
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
