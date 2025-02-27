import 'package:flutter/material.dart';

import '../../../common_widgets/all.dart';
import '../../../resource/styles/app_colors.dart';

class CallHistoryAppBar extends CommonAppBar {
  CallHistoryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      leadingIconColor: AppColors.pacificBlue,
      leadingIcon: LeadingIcon.none,
      automaticallyImplyLeading: false,
      centerTitle: false,
      // automaticallyImplyLeading: false ,
      // titleType: AppBarTitle.none,
      // leadingIconColor: AppColors.pacificBlue,

      // titleWidget: GetBuilder<CallGatewayController>(
      //   builder: (callGatewayController) {
      //     return GetBuilder(
      //       init: Get.find<CallHistoryController>(),
      //       builder: (controller) {
      //         if (callGatewayController.currentIndex.value == 2) {
      //           return SlidingSwitch(
      //             value: controller.switchCallHistory.value,
      //             textOn: callGatewayController.l10n.call_history__missed,
      //             textOff: callGatewayController.l10n.call_history__all,
      //             colorOn: AppColors.white,
      //             colorOff: AppColors.white,
      //             inactiveColor: AppColors.text4,
      //             contentSize: 14,
      //             width: 230.w,
      //             height: 55.h,
      //             onChanged: (value) {
      //               controller.updateCallHistoryAppBar(value);
      //             },
      //             onTap: () {},
      //             onSwipe: () {},
      //           );
      //         }

      //         return const SizedBox();
      //       },
      //     );
      //   },
      // ),
    );
  }
}
