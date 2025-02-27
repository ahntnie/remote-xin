import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widgets/shimmer.dart';
import '../../../../../resource/resource.dart';

class ShimmerLoadingConversation extends StatelessWidget {
  const ShimmerLoadingConversation({super.key});

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildContainer(14, 0.2.sw, false, 100),
                AppSpacing.gapH4,
                buildContainer(14, 0.6.sw, false, 100),
              ],
            )
          ],
        ).paddingOnly(left: 20, right: 20, top: 20));
  }
}
