import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/all.dart';
import '../../common_widgets/app_icon.dart';
import '../../resource/styles/app_colors.dart';
import '../../resource/styles/gaps.dart';
import '../../routing/routers/app_pages.dart';
import 'notification_controller.dart';

class NotificationsIcon extends StatelessWidget {
  const NotificationsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (controller) {
        return Stack(
          children: [
            _buildIcon(context),
            if (controller.unreadNotificationsCount > 0)
              Positioned(
                right: 0,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xffBE0000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  // child: Text(
                  //   controller.unreadNotificationsCount.toString(),
                  //   style: const TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 12,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                ),
              ),
          ],
        ).clickable(() => Get.toNamed(Routes.notification));
      },
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: Sizes.s2,
        right: Sizes.s2,
        top: Sizes.s8,
      ),
      padding: const EdgeInsets.all(Sizes.s8),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey6,
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   stops: [0.0, 1.0],
        //   colors: AppColors.button2,
        // ),
        // border: Border.all(color: AppColors.grey1.withOpacity(0.67)),
      ),
      child: AppIcon(
        icon: AppIcons.bell,
        // padding: const EdgeInsets.all(Sizes.s8),
        color: AppColors.text2,
      ),
    );
  }
}
