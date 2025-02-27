import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widgets/shimmer.dart';
import '../../../../resource/styles/styles.dart';

class ShimmerLoadingContact extends StatelessWidget {
  const ShimmerLoadingContact({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildContainer(
            double height, double width, bool isCircle, double radius) =>
        Container(
          height: height,
          width: width,
          decoration: isCircle
              ? BoxDecoration(
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                  color: AppColors.white,
                )
              : BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(radius)),
        );
    return Shimmer.fromColors(
        baseColor: AppColors.blue7,
        highlightColor: AppColors.blue7.withOpacity(0.5),
        child: Row(
          children: [
            buildContainer(48, 48, true, 100),
            AppSpacing.gapW12,
            buildContainer(14, 0.2.sw, false, 100)
          ],
        ).paddingOnly(right: 20, top: 12));
  }
}
