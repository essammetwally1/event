import 'package:event/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomCreateEventRow extends StatelessWidget {
  final String iconName;
  final String label;

  const CustomCreateEventRow({
    super.key,
    required this.textTheme,
    required this.iconName,
    required this.label,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/$iconName.svg',
          height: 20,
          width: 20,
          fit: BoxFit.fill,
        ),
        SizedBox(width: 8),
        Text(
          'Event $label',
          style: textTheme.titleMedium!.copyWith(color: AppTheme.black),
        ),
        Spacer(),
        TextButton(
          onPressed: () {},
          child: Text('Choose $label', style: textTheme.titleMedium),
        ),
      ],
    );
  }
}
