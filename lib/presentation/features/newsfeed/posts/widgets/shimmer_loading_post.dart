import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widgets/shimmer.dart';
import '../../../../resource/resource.dart';

class ShimmerLoadingPost extends StatelessWidget {
  const ShimmerLoadingPost({super.key});

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
        highlightColor: AppColors.blue7.withOpacity(0.4),
        child: IntrinsicHeight(
          child: Column(
            children: [
              Row(
                children: [
                  buildContainer(48, 48, true, 100),
                  AppSpacing.gapW12,
                  Column(
                    children: [
                      buildContainer(14, 0.2.sw, false, 100),
                      AppSpacing.gapH4,
                      buildContainer(14, 0.2.sw, false, 100),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s16),
              buildContainer(100.h, double.infinity, false, 20)
                  .paddingOnly(right: 20, bottom: 12, left: 20)
            ],
          ),
        ));
  }
}
