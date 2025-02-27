import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';
import '../all.dart';

class OtpReceiveView extends BaseView<OtpReceiveController> {
  const OtpReceiveView({
    Key? key,
  }) : super(key: key);

  // Widget _buildOtpInput(BuildContext context) {
  //   return Padding(
  //     padding: EdgeInsets.only(bottom: 33.h),
  //     child: PinCodeTextField(
  //       scrollPadding: EdgeInsets.zero,
  //       appContext: context,
  //       errorTextSpace: 0,
  //       length: 6,
  //       controller: controller.otpController,
  //       // autoFocus: true,
  //       animationType: AnimationType.fade,
  //       keyboardType: TextInputType.number,
  //       onChanged: (value) {
  //         controller.setDisableSubmitBtn = !(value.length == 6);
  //         if (value.length == 6) {
  //           controller.submit();
  //         }
  //       },
  //       // validator: controller.validateOtp,
  //       hintCharacter: '',
  //       textStyle: AppTextStyles.s20w700,
  //       enableActiveFill: true,

  //       pinTheme: PinTheme(
  //         fieldOuterPadding: EdgeInsets.symmetric(horizontal: 2.r),
  //         borderRadius: BorderRadius.circular(6.r),
  //         shape: PinCodeFieldShape.box,
  //         activeFillColor: AppColors.label1Color,
  //         inactiveFillColor: AppColors.label1Color,
  //         inactiveColor: AppColors.label1Color,
  //         activeColor: AppColors.label1Color,
  //         selectedColor: AppColors.label1Color,
  //         selectedFillColor: AppColors.label1Color,
  //         fieldHeight: 50.sp,
  //         fieldWidth: 50.sp,
  //         borderWidth: 1.5,
  //       ),
  //       textCapitalization: TextCapitalization.characters,
  //     ),
  //   );
  // }

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
                  final loginController = Get.find<LoginController>();
                  if (loginController.isRegister.value) {
                    controller.resendOtpRegister();
                  } else {
                    controller.resendOtpForgotPassword();
                  }
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
        controller.submit();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.gapH20,
        Text(
          l10n.text_verify_email,
          style: AppTextStyles.s26w700.toColor(AppColors.blue10),
        ),
        GetBuilder<LoginController>(builder: (controller) {
          if (controller.emailController.text.trim().isEmpty ||
              controller.isRegister.value) {
            final regController = Get.find<RegisterController>();

            return regController.emailController.text.trim().isEmpty
                ? const SizedBox()
                : RegExp(regController.emailPattern)
                        .hasMatch(regController.emailController.text)
                    ? Text(
                        '${l10n.otp_receive__hint_text} ${regController.emailController.text}',
                        style: AppTextStyles.s14w500.toColor(AppColors.grey8))
                    : Text(
                        '${l10n.otp_receive__hint_text} ${regController.phoneRegister.value}',
                        style: AppTextStyles.s14w500.toColor(AppColors.grey8));
          }

          return Text(
            RegExp(controller.emailPattern)
                    .hasMatch(controller.emailController.text)
                ? '${l10n.otp_receive__hint_text} ${controller.emailController.text}'
                : '${l10n.otp_receive__hint_text} ${controller.phoneLogin.value}',
            style: AppTextStyles.s14w500.toColor(AppColors.grey8),
          );
        }),
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
