import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/const_res.dart';
import '../utils/font_res.dart';

class ImagePlaceHolder extends StatelessWidget {
  final String? name;
  final double? heightWeight;
  final double? fontSize;
  final bool isRound;

  const ImagePlaceHolder(
      {super.key,
      this.name,
      this.heightWeight = 90,
      this.fontSize,
      this.isRound = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightWeight,
      width: heightWeight,
      decoration: BoxDecoration(
        color: ColorRes.colorPrimary,
        shape: !isRound ? BoxShape.rectangle : BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        (name?.replaceAll(RegExp(r'[0-9]+'), '')[0] ?? defaultPlaceHolderText)
            .toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: fontSize ?? 70,
            fontFamily: FontRes.fNSfUiSemiBold,
            color: ColorRes.colorTextLight),
      ),
    );
  }
}
