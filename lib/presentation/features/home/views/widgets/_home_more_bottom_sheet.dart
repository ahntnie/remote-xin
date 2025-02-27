import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../common_widgets/app_blurry_container.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../../../resource/styles/text_styles.dart';
import '../../../../routing/routers/app_pages.dart';
import '../../home.dart';

class HomeMoreBottomSheet extends StatelessWidget {
  final HomeController controller;

  const HomeMoreBottomSheet({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBlurryContainer(
      padding: EdgeInsets.zero,
      child: Container(
        height: 0.2.sh,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              children: [
                _buildItemAccount(context),
                _buildItemLogout(context),
              ],
            ),
            _bottomSheetClose(context),
          ],
        ),
      ),
    );
  }

  Widget _buildItemLogout(BuildContext context) {
    return _buildItemBottomSheet(
      AppIcon(
        icon: AppIcons.logout,
        size: 33.w,
        color: AppColors.negative,
      ),
      context.l10n.home__bottom_sheet_logout,
      color: AppColors.negative,
      onTap: () => controller.logout(),
    );
  }

  Widget _buildItemAccount(BuildContext context) {
    return _buildItemBottomSheet(
      AppCircleAvatar(
        url: controller.currentUser.avatarPath ?? '',
        size: 33.w,
        backgroundColor: Colors.transparent,
      ),
      context.l10n.home__bottom_sheet_account,
      onTap: () => Get.toNamed(
        Routes.profile,
        arguments: {'isUpdateProfileFirstLogin': false},
      ),
    );
  }

  Widget _buildItemBottomSheet(
    Widget icon,
    String title, {
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          icon,
          SizedBox(
            height: 10.h,
          ),
          Text(
            title,
            style: AppTextStyles.s14w400.copyWith(color: color),
          ),
        ],
      ),
    ).clickable(() {
      Get.back();
      onTap();
    });
  }

  Widget _bottomSheetClose(BuildContext context) {
    return AppIcon(
      icon: AppIcons.close,
      isCircle: true,
      backgroundColor: AppColors.label45,
      padding: EdgeInsets.all(10.w),
    ).clickable(Get.back);
  }
}
