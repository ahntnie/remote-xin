import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../services/deep_link/deep_link_service.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/gen/assets.gen.dart';
import '../../../resource/styles/app_colors.dart';
import '../../../resource/styles/gaps.dart';
import '../../../routing/routing.dart';
import '../../scan_qr/scan_qr_view.dart';
import '../all.dart';

class PersonalPageAppBarView extends CommonAppBar {
  PersonalPageAppBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalPageController>(
      init: Get.find<PersonalPageController>(),
      builder: (controller) {
        return CommonAppBar(
          // backgroundColor: AppColors.blue1,
          titleWidget: const AppLogo(),
          leadingIconColor: AppColors.pacificBlue,
          leadingIcon: LeadingIcon.none,
          automaticallyImplyLeading: false,
          centerTitle: false,
          backgroundColor: Colors.white,
          actions: [
            _buildIcon(
                icon: AppIcons.edit,
                appIcon: AppIcon(
                  icon: Assets.icons.scan,
                  color: Colors.black,
                ),
                onTap: () async {
                  final value = await Get.to(() => const ScanQrView());
                  print(value);

                  if (value != null) {
                    final String link = value;
                    // scan deep link
                    if (link.startsWith(kDeepLinkPrefix)) {
                      // ViewUtil.showToast(
                      //   title: context.l10n.global__success_title,
                      //   message: context.l10n.scan__scan_success,
                      // );
                      final deepLinkService = Get.find<DeepLinkService>();

                      deepLinkService.handleDeepLink(link);
                    }
                  }
                }),
            AppSpacing.gapW12,
            _buildIcon(
              icon: AppIcons.setting,
              onTap: () {
                Get.toNamed(Routes.setting);
              },
            ),
          ],
          // flexibleSpace: Container(
          //   padding: EdgeInsets.only(
          //     left: Sizes.s20,
          //     right: Sizes.s20,
          //     top: Sizes.s28.h,
          //   ),
          //   child: Obx(
          //     () => Row(
          //       children: [
          //         AppCircleAvatar(
          //           url: controller.currentUserRx.value?.avatarPath ?? '',
          //         ),
          //         AppSpacing.gapW12,
          //         Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             Text(
          //               (controller.currentUserRx.value?.nickname ?? '')
          //                       .isNotEmpty
          //                   ? controller.currentUserRx.value?.nickname ?? ''
          //                   : controller.currentUserRx.value?.fullName ?? '',
          //               style: AppTextStyles.s18w600.text2Color
          //                   .copyWith(fontSize: 18.sp),
          //             ),
          //             Text(
          //               controller.phoneNumber.value,
          //               style: AppTextStyles.s14w600.copyWith(
          //                 fontSize: 14.sp,
          //                 color: AppColors.zambezi,
          //               ),
          //             ),
          //           ],
          //         ),
          //         const Expanded(child: SizedBox.shrink()),
          //         _buildIcon(
          //             icon: AppIcons.edit,
          //             appIcon: const AppIcon(
          //               icon: Icons.crop_free,
          //               color: Colors.black,
          //             ),
          //             onTap: () async {
          //               final value = await Get.to(() => const ScanQrView());
          //               print(value);

          //               if (value != null) {
          //                 final String link = value;
          //                 // scan deep link
          //                 if (link.startsWith(kDeepLinkPrefix)) {
          //                   // ViewUtil.showToast(
          //                   //   title: context.l10n.global__success_title,
          //                   //   message: context.l10n.scan__scan_success,
          //                   // );
          //                   final deepLinkService = Get.find<DeepLinkService>();

          //                   deepLinkService.handleDeepLink(link);
          //                 }
          //               }
          //             }),
          //         // AppSpacing.gapW12,
          //         // _buildIcon(
          //         //   icon: AppIcons.edit,
          //         //   onTap: () {
          //         //     Get.toNamed(
          //         //       Routes.profile,
          //         //       arguments: {'isUpdateProfileFirstLogin': false},
          //         //     );
          //         //   },
          //         // ),
          //         AppSpacing.gapW12,
          //         _buildIcon(
          //           icon: AppIcons.setting,
          //           onTap: () {
          //             Get.toNamed(Routes.setting);
          //           },
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        );
      },
    );
  }

  Widget _buildIcon({
    required SvgGenImage icon,
    required Function() onTap,
    AppIcon? appIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(Sizes.s8),
      decoration: const BoxDecoration(
        color: AppColors.grey6,
        shape: BoxShape.circle,
      ),
      child: appIcon ??
          AppIcon(
            icon: icon,
            color: Colors.black,
          ),
    ).clickable(() {
      onTap();
    });
  }
}
