import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../common_controller.dart/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';
import '../../../view/live_stream/model/broad_cast_screen_view_model.dart';

class BroadCastTopBarArea extends StatelessWidget {
  final BroadCastScreenViewModel model;

  const BroadCastTopBarArea({
    required this.model,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppCircleAvatar(
                      url: appController.lastLoggedUser?.avatarPath ?? '',
                      size: 40,
                    ),
                    AppSpacing.gapW4,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appController.lastLoggedUser?.fullName ?? '',
                          style: AppTextStyles.s12w600.text2Color
                              .copyWith(fontSize: 13),
                        ).paddingOnly(right: 4),
                        Row(
                          children: [
                            // AppIcon(
                            //   icon: Assets.images.diamond,
                            //   size: 12,
                            // ),
                            AppSpacing.gapW4,
                            Text(
                              (model.liveStreamUser?.collectedDiamond ?? 0)
                                  .toString(),
                              style: AppTextStyles.s12w400
                                  .copyWith(fontSize: 11, color: Colors.white),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    // AppIcon(
                    //   icon: Assets.icons.eye,
                    //   color: Colors.white,
                    //   size: 18,
                    // ),
                    AppSpacing.gapW4,
                    Text(
                      (model.liveStreamUser?.watchingCount ?? 0).toString(),
                      style: AppTextStyles.s14w500.text2Color
                          .copyWith(fontSize: 12),
                    )
                  ],
                ),
              ),
              AppSpacing.gapW8,
              AppIcon(
                icon: Assets.icons.close,
                color: AppColors.white,
                size: 28,
                onTap: model.onEndButtonClick,
              )
            ],
          ).paddingSymmetric(horizontal: 12),

          Container(
            padding: const EdgeInsets.only(right: 12),
            width: 1.sw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // AppIcon(
                //   icon:
                //       !model.isMic ? Assets.icons.callMic : Assets.icons.micOff,
                //   color: AppColors.white,
                //   size: 28,
                //   onTap: model.onMuteUnMute,
                // ),
                AppSpacing.gapH20,
                AppIcon(
                  icon: Assets.icons.video,
                  color: AppColors.white,
                  onTap: model.flipCamera,
                  size: 19,
                )
              ],
            ),
          )
          // BlurTab(
          //   child: Row(
          //     children: [
          //       const SizedBox(
          //         width: 10,
          //       ),
          //       Image.asset(
          //         Provider.of<MyLoading>(context).isDark ? icLogo : icLogoLight,
          //         height: 25,
          //         width: 25,
          //       ),
          //       const SizedBox(
          //         width: 5,
          //       ),
          //       Text(
          //         "${NumberFormat.compact(locale: 'en').format(model.liveStreamUser?.collectedDiamond ?? 0)} Collected",
          //         style: const TextStyle(color: ColorRes.white),
          //       ),
          //       const Spacer(),
          //       InkWell(
          //         onTap: model.flipCamera,
          //         child: Container(
          //           padding: const EdgeInsets.all(11),
          //           margin: const EdgeInsets.all(3),
          //           decoration: const BoxDecoration(
          //               shape: BoxShape.circle,
          //               gradient: LinearGradient(
          //                   colors: [ColorRes.colorTheme, ColorRes.colorPink])),
          //           alignment: Alignment.center,
          //           child: Image.asset(flipCamera, color: ColorRes.white),
          //         ),
          //       ),
          //       InkWell(
          //         onTap: model.onMuteUnMute,
          //         child: Container(
          //           padding: const EdgeInsets.all(11),
          //           margin: const EdgeInsets.all(3),
          //           decoration: const BoxDecoration(
          //               gradient: LinearGradient(
          //                   colors: [ColorRes.colorTheme, ColorRes.colorPink]),
          //               shape: BoxShape.circle),
          //           alignment: Alignment.center,
          //           child: Icon(
          //             !model.isMic ? Icons.mic : Icons.mic_off,
          //             color: ColorRes.white,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
