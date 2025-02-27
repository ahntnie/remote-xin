import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';

class LoginTextFiled extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool isDarkMode;

  const LoginTextFiled(
      {required this.controller,
      required this.focusNode,
      required this.obscureText,
      required this.keyboardType,
      required this.isDarkMode,
      Key? key,
      this.textCapitalization = TextCapitalization.none})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: isDarkMode ? ColorRes.colorPrimary : ColorRes.greyShade100,
          borderRadius: BorderRadius.circular(5)),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        ),
        cursorColor: ColorRes.colorTextLight,
        cursorHeight: 15,
        style: const TextStyle(
            color: ColorRes.colorTextLight,
            fontSize: 15,
            fontFamily: FontRes.fNSfUiMedium),
      ),
    );
  }
}
