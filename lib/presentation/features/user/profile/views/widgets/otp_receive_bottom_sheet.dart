import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../base/base_view.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/styles/app_colors.dart';
import '../../../../../resource/styles/gaps.dart';
import '../../../../../resource/styles/text_styles.dart';
import '../../../../all.dart';

class OtpReceiveBottomSheet extends BaseView<ProfileController> {
  const OtpReceiveBottomSheet({
    Key? key,
  }) : super(key: key);

  Widget _buildOtpInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
      decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.grey8,
          ),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], // Only numbers can be entered
              controller: controller.otpController,
              style: AppTextStyles.s16w500.text2Color,
              cursorColor: AppColors.text2,

              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.white,
                  filled: true,
                  isDense: true,
                  hintText: l10n.your_otp,
                  hintStyle: AppTextStyles.s16w400.copyWith(
                    color: AppColors.subText2,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none),

              textInputAction: TextInputAction.done,
              onChanged: (value) {
                // if (value.length == 6) {
                //   controller.submit();
                // }
                if (value.length > 6) {
                  final res = value.substring(0, value.length - 1);
                  controller.otpController.text = res;
                } else {
                  controller.setDisableSubmitBtn = !(value.length == 6);
                }
              },
            ),
          ),
          _buildTimeCount()
        ],
      ),
    );
  }

  String _formatTime(int totalSecond) {
    if (totalSecond == 0) {
      return '';
    }
    final minute = totalSecond ~/ 60;
    final second = totalSecond % 60;

    return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}s';
  }

  Widget _buildTimeCount() {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          controller.otpTimeLeft.value == 0
              ? Text(
                  l10n.button__resend_otp,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.s16w500.toColor(AppColors.blue10),
                ).clickable(() {
                  controller.resendOtpRegister();
                })
              : Text(
                  _formatTime(controller.otpTimeLeft.value),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.s16w500.negativeColor,
                ),
        ],
      ),
    );
  }

  Widget _buildSubmitBtn() {
    return AppButton.primary(
      label: l10n.button__continue,
      width: double.infinity,
      onPressed: () {
        controller.submitOtp();
        // if (flowFrom == Routes.register) {
        //   Get.find<ResetPasswordController>().otp =
        //       controller.otpController.text;
        //   Get.find<RegisterController>().nextPage();
        // } else {
        //   Get.find<ResetPasswordController>().otp =
        //       controller.otpController.text;
        //   Get.find<LoginController>().nextPage();
        // }
      },
      isLoading: controller.isLoading,
      isDisabled: controller.isDisableSubmitBtn.value,
    );
  }

  Widget _buildResendOtpBtn() {
    // return Padding(
    //   padding: EdgeInsets.only(top: 28.h),
    //   child: GestureDetector(
    //     onTap: () {
    //       controller.resendOtpRegister();
    //     },
    //     child: Text(
    //       l10n.button__resend_otp,
    //       style: AppTextStyles.s18w500.copyWith(
    //         color: controller.otpTimeLeft.value != 0
    //             ? AppColors.disable
    //             : AppColors.stoke,
    //       ),
    //     ),
    //   ),
    // );

    return Padding(
      padding: EdgeInsets.only(top: 28.h),
      child: AppButton.primary(
        label: l10n.button__resend_otp,
        width: double.infinity,
        onPressed: () {
          controller.resendOtpRegister();
        },
        isLoading: controller.isLoading,
        isDisabled: controller.otpTimeLeft.value != 0,
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.gapH20,
          Text(
            l10n.text_verify_email,
            style: AppTextStyles.s26w700.toColor(AppColors.blue10),
          ),
          Text(
              '${l10n.otp_receive__hint_text} ${(controller.currentUser.email ?? '').isEmpty ? controller.email.value : controller.phoneEdit.value}',
              style: AppTextStyles.s14w500.toColor(AppColors.grey8)),
          AppSpacing.gapH32,
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOtpInput(context),
                AppSpacing.gapH32,
                _buildSubmitBtn(),
              ],
            ),
          ),
        ],
      ),
    );
    // CommonScaffold(
    //   hideKeyboardWhenTouchOutside: true,
    //   appBar: CommonAppBar(
    //     titleType: AppBarTitle.none,
    //     // titleWidget: Text(
    //     //   l10n.button__sign_up,
    //     //   style: AppTextStyles.s14w400.copyWith(color: AppColors.pacificBlue),
    //     // ),
    //     leadingIconColor: AppColors.pacificBlue,
    //     centerTitle: false,
    //   ),
    //   body: Obx(
    //     () => SingleChildScrollView(
    //       child: Padding(
    //         padding: EdgeInsets.symmetric(horizontal: 18.w),
    //         child: Form(
    //           key: controller.formKey,
    //           child: Column(
    //             children: [
    //               _buildOtpInput(context),
    //               // _buildTimeCount(),
    //               // _buildSubmitBtn(),
    //               _buildResendOtpBtn(),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
