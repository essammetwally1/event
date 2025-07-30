import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final String? iconPathName;
  final TextEditingController? controller;
  final void Function(String)? onChange;
  final int? maxLines;
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.iconPathName,
    this.controller,
    this.onChange,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      onChanged: onChange,
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
