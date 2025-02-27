import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common_widgets/shimmer.dart';
import '../../../../resource/styles/styles.dart';

class ShimmerLoadingMission extends StatelessWidget {
  const ShimmerLoadingMission({super.key});

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
        child: Container(
          width: 132.w,
          height: 189.h,
          margin: const EdgeInsets.only(right: Sizes.s8),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                child: Container(
                  height: 176.h,
                  width: 132.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.pacificBlue),
                    borderRadius: BorderRadius.circular(Sizes.s8),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: Sizes.s8.h,
                    horizontal: Sizes.s12.w,
                  ),
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      buildContainer(50.w, 50.w, true, 100),
                      AppSpacing.gapH8,
                      buildContainer(20.w, 100.w, false, 20),
                      AppSpacing.gapH8,
                      buildContainer(20.w, 100.w, false, 20)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
