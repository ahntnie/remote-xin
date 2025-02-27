import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'size_config.dart';

double animatedPositionedLEftValue(int currentIndex) {
  // final spaceWidth = (1.sw - 40 - 1.sw / 7 * 5) / 4;

  // return (spaceWidth + 1.sw / 7) * currentIndex;

  final spaceWidth = (1.sw - 40 - AppSizes.blockSizeHorizontal * 4) / 3;

  return (spaceWidth + AppSizes.blockSizeHorizontal) * currentIndex;
}
//
// Created by CodeWithFlexZ
// Tutorials on my YouTube
//
//! Instagram
//! @CodeWithFlexZ
//
//? GitHub
//? AmirBayat0
//
//* YouTube
//* Programming with FlexZ
//

final List<Color> gradient = [
  Colors.yellow.withOpacity(0.8),
  Colors.yellow.withOpacity(0.5),
  Colors.transparent
];
