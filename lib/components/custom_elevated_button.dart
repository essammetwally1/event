import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String textElevatedButton;
  final VoidCallback onPressed;
  const CustomElevatedButton({
    super.key,
    required this.textElevatedButton,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(MediaQuery.sizeOf(context).width, 56),
      ),
      onPressed: onPressed,
      child: Text(textElevatedButton, style: TextTheme.of(context).titleLarge),
    );
  }
}
