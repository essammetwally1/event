import 'package:event/app_theme.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String textElevatedButton;
  final VoidCallback onPressed;
  final bool isLoading;
  const CustomElevatedButton({
    super.key,
    required this.textElevatedButton,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(MediaQuery.sizeOf(context).width, 56),
      ),
      onPressed: onPressed,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.backgroundWhite),
            )
          : Text(textElevatedButton, style: TextTheme.of(context).titleLarge),
    );
  }
}
