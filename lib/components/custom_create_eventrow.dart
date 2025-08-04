import 'package:event/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class CustomCreateEventRow extends StatelessWidget {
  final String iconName;
  final String label;
  final void Function()? onPressed;
  final DateTime? date;
  final TimeOfDay? time;

  const CustomCreateEventRow({
    super.key,
    required this.textTheme,
    required this.iconName,
    required this.label,
    this.onPressed,
    this.date,
    this.time,
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
          onPressed: onPressed,
          child: Text(
            date != null || time != null
                ? [
                    if (date != null) DateFormat('MMM d, yyyy').format(date!),
                    if (time != null)
                      DateFormat(
                        'h:mm a',
                      ).format(DateTime(2023, 1, 1, time!.hour, time!.minute)),
                  ].join(' at ')
                : 'Choose $label',
            style: textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
