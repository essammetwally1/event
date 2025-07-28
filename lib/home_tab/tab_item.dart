import 'package:flutter/material.dart';

class TapItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedBackgroundColor;
  final Color unSelectedBackgroundColor;
  final Color foreginSelectedColor;
  final Color foreginUnSelectedColor;

  const TapItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedBackgroundColor,
    required this.unSelectedBackgroundColor,
    required this.foreginSelectedColor,
    required this.foreginUnSelectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 19, vertical: 11),
      decoration: BoxDecoration(
        color: isSelected ? selectedBackgroundColor : unSelectedBackgroundColor,
        borderRadius: BorderRadius.circular(46),
        border: isSelected
            ? null
            : BoxBorder.all(color: foreginUnSelectedColor),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? foreginSelectedColor : foreginUnSelectedColor,
            size: 24,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: isSelected ? foreginSelectedColor : foreginUnSelectedColor,
            ),
          ),
        ],
      ),
    );
  }
}
