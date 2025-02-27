import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import 'all.dart';

class PostInputResourceCollapsedView
    extends GetView<PostInputResourceController> {
  const PostInputResourceCollapsedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: Sizes.s12.h,
        bottom: Sizes.s16.h,
        left: Sizes.s20,
        right: Sizes.s20,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Sizes.s20),
          topRight: Radius.circular(Sizes.s20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.text2.withOpacity(0.27),
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 4,
            margin: EdgeInsets.only(bottom: Sizes.s12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.grey10,
            ),
          ),
          const Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AppIcon(icon: AppIcons.image, color: AppColors.green1)
                  .clickable(() {
                controller.pickMedia();
              }),
              AppIcon(icon: AppIcons.camera, color: AppColors.blue4)
                  .clickable(() {
                controller.takePhotoFromCamera();
              }),
            ],
          ),
        ],
      ),
    );
  }
}
