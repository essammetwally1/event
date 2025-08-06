import 'package:event/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? iconPathName;
  final TextEditingController? controller;
  final void Function(String)? onChange;
  final int? maxLines;
  final String? Function(String?)? validator;
  const CustomTextFormField({
    super.key,
    this.hintText,
    this.iconPathName,
    this.controller,
    this.onChange,
    this.maxLines,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      maxLines: maxLines,
      controller: controller,

      onChanged: onChange,
      cursorColor: AppTheme.primary,
      style: Theme.of(context).textTheme.titleMedium,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: iconPathName == null
            ? null
            : SvgPicture.asset(
                'assets/icons/$iconPathName.svg',
                width: 24,
                height: 24,
                fit: BoxFit.scaleDown,
              ),
      ),
    );
  }
}
