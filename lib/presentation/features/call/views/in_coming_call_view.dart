import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../base/all.dart';
import '../../../resource/resource.dart';
import '../controllers/in_coming_call_controller.dart';
import 'widgets/info_user_widget.dart';

class InComingCallView extends BaseView<InComingCallController> {
  const InComingCallView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage(Assets.images.chatBackground.path),
              //   fit: BoxFit.fill,
              // ),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.background7)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0.3.sh,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Obx(
                      () => InfoUserWidget(
                        user: controller.caller,
                        isTranslate: false,
                      ),
                    ),
                    AppSpacing.gapH20,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          controller.isVideoCall()
                              ? Icons.videocam_rounded
                              : Icons.call,
                          color: Colors.black,
                          size: Sizes.s16,
                        ),
                        AppSpacing.gapW8,
                        Text(
                          controller.isVideoCall()
                              ? l10n.call_video_calling
                              : l10n.call_voice_calling,
                          style: AppTextStyles.s14w400
                              .copyWith(color: AppColors.text2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 50,
                width: Get.width,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: Sizes.s16,
                    right: Sizes.s16,
                    top: Sizes.s16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppSpacing.gapW32,
                      InkWell(
                        onTap: controller.onDecline,
                        child: Column(
                          children: [
                            const CircleAvatar(
                              foregroundColor: AppColors.negative,
                              backgroundColor: AppColors.negative,
                              radius: Sizes.s36,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: Sizes.s36,
                              ),
                            ),
                            AppSpacing.gapH16,
                            Text(
                              l10n.call_decline_title,
                              style: AppTextStyles.s16w500.text2Color,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: controller.onAccept,
                        child: Column(
                          children: [
                            const CircleAvatar(
                              foregroundColor: AppColors.positive,
                              backgroundColor: AppColors.positive,
                              radius: Sizes.s36,
                              child: Icon(
                                Icons.call,
                                color: Colors.white,
                                size: Sizes.s36,
                              ),
                            ),
                            AppSpacing.gapH16,
                            Text(
                              l10n.call_accept_title,
                              style: AppTextStyles.s16w500.text2Color,
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.gapW32,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
