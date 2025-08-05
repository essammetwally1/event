import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionIconButton extends StatelessWidget {
  final String iconPath;
  final void Function() onPressed;
  final Color? iconColor;
  final double size;

  const ActionIconButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
    this.iconColor,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: SvgPicture.asset(
        'assets/icons/$iconPath.svg',
        width: size,
        height: size,
        // colorFilter: iconColor != null
        //     ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
        //     : null,
      ),
      onPressed: onPressed,
      splashRadius: size / 2, // Custom splash radius
      padding: EdgeInsets.zero, // Remove default padding
      constraints: BoxConstraints(
        minWidth: size + 8, // Add some padding for touch area
        minHeight: size + 8,
      ),
    );
  }
}
