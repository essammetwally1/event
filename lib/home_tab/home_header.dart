import 'package:event/app_theme.dart';
import 'package:event/home_tab/tab_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
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
          length: 2,

          child: TabBar(
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            isScrollable: true,
            labelPadding: EdgeInsets.only(right: 10),
            tabs: [
              TapItem(
                label: 'All',
                icon: Icons.safety_check,
                isSelected: true,
                selectedBackgroundColor: AppTheme.backgroundWhite,
                unSelectedBackgroundColor: AppTheme.primary,
                foreginSelectedColor: AppTheme.primary,
                foreginUnSelectedColor: AppTheme.backgroundWhite,
              ),
              TapItem(
                label: 'Meeting',
                icon: Icons.meeting_room,
                isSelected: false,
                selectedBackgroundColor: AppTheme.backgroundWhite,
                unSelectedBackgroundColor: AppTheme.primary,
                foreginSelectedColor: AppTheme.primary,
                foreginUnSelectedColor: AppTheme.backgroundWhite,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
