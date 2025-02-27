import 'package:flutter/material.dart';

import '../../../../../resource/resource.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String name;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextCapitalization? textCapitalization;
  final TextInputType? inputType;
  final Function(String)? onChanged;
  final Function()? onTap;
  final FocusNode focusNode;
  final Color? backgroundColor;

  const CustomTextField({
    required this.name,
    required this.focusNode,
    this.prefixIcon,
    this.inputType,
    Key? key,
    this.controller,
    this.obscureText = false,
    this.onChanged,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        focusNode: focusNode,
        onTap: onTap,
        enabled: true,
        controller: controller,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        obscureText: obscureText,
        keyboardType: inputType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        onChanged: (value) {
          onChanged!(value);
        },
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: backgroundColor,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          isDense: true,
          labelText: name,
          counterText: '',
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(
            // borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          focusedBorder: const OutlineInputBorder(
            // borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          enabledBorder: const OutlineInputBorder(
            // borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
    );
  }
}
