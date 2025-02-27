import 'package:flutter/material.dart';

import '../../presentation/resource/styles/app_colors.dart';

extension TextStyleExtensions on TextStyle {
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  TextStyle get w300 => copyWith(fontWeight: FontWeight.w300);
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);
  TextStyle get w700 => copyWith(fontWeight: FontWeight.w700);

  TextStyle toColor(Color color) => copyWith(color: color);

  TextStyle get text1Color => toColor(AppColors.text1);
  TextStyle get text2Color => toColor(AppColors.text2);
  TextStyle get text4Color => toColor(AppColors.zambezi);
  TextStyle get subText1Color => toColor(AppColors.subText1);
  TextStyle get subText2Color => toColor(AppColors.subText2);
  TextStyle get negativeColor => toColor(AppColors.negative);
  TextStyle get positiveColor => toColor(AppColors.positive);
}
