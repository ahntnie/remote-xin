import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../base/all.dart';
import '../../../../common_controller.dart/language_controller.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';
import '../../../user/settings/widgets/choose_language_view.dart';
import '../../otp_receive/all.dart';
import '../../reset_password/controllers/reset_password_controller.dart';

class AuthOptionView extends BaseView<AuthOptionController> {
  const AuthOptionView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned(
                right: 0,
                bottom: 0,
                child: Assets.images.backgroundSplash.image(scale: 2.2)),
            SafeArea(
                child: Padding(
              padding: AppSpacing.edgeInsetsH20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapH8,
                  Align(
                      alignment: Alignment.topRight,
                      child: _buildLanguageButton(context)),
                  AppSpacing.gapH8,
                  Text(
                    l10n.text_welcome_to_xintel,
                    style: AppTextStyles.s28w600.copyWith(
                        color: AppColors.blue10,
                        fontSize:
                            Get.find<LanguageController>().currentIndex.value ==
                                    0
                                ? 28
                                : 32),
                  ),
                  AppSpacing.gapH16,
                  Text(
                    l10n.text_discover_seamless_connections,
                    style: AppTextStyles.s16Base.toColor(AppColors.grey8),
                  ),
                  AppSpacing.gapH20,
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 0.4.sw),
                    child: AppButton.primary(
                      // width: 0.45.sw,
                      label: l10n.text_lets_get_started,
                      onPressed: () => showBottomSheetOption(context),
                    ),
                  )
                ],
              ),
            )),
          ],
        ));
  }

  Widget _buildLanguageButton(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.grey8)),
        child: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleFlag(
                    size: 24,
                    Get.find<LanguageController>().languages[
                            Get.find<LanguageController>()
                                .currentIndex
                                .value]['flagCode'] ??
                        ''),
                AppSpacing.gapW8,
                Text(
                  Get.find<LanguageController>().languages[
                              Get.find<LanguageController>().currentIndex.value]
                          ['code'] ??
                      '',
                  style: AppTextStyles.s16w600.copyWith(color: AppColors.text2),
                ),
              ],
            ).clickable(() {
              // ViewUtil.showBottomSheet(
              //   isFullScreen: true,
              //   child: const ChooseLanguageView(),
              // );
              Get.to(() => const ChooseLanguageView(),
                  transition: Transition.cupertino);
            })),
      );

  void showBottomSheetOption(BuildContext context) {
    try {
      Get.find<LoginController>().reset();
      Get.find<RegisterController>().reset();

      Get.find<OtpReceiveController>().reset();

      Get.find<ResetPasswordController>().reset();
    } catch (e) {
      LogUtil.e(e);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const LoginView(),
      useSafeArea: true,
    );
  }
}
