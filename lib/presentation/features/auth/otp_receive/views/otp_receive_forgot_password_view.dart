import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../all.dart';

class OtpReceiveForgotPasswordView extends BaseView<OtpReceiveController> {
  const OtpReceiveForgotPasswordView({Key? key}) : super(key: key);

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
    return Padding(
      padding: EdgeInsets.only(bottom: 0.h),
      child: AppTextField(
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ], // Only numbers can be entered
        controller: controller.otpController,
        hintText: l10n.your_otp,
        hintStyle: AppTextStyles.s16w400.copyWith(
          color: AppColors.subText2,
          fontStyle: FontStyle.italic,
        ),
        label: l10n.enter_otp_label,
        textInputAction: TextInputAction.done,
        contentPadding: EdgeInsets.all(17.w),
        onChanged: (value) {
          controller.setDisableSubmitBtn = !(value.length == 6);
          // if (value.length == 6) {
          //   controller.submit();
          // }
        },
        suffixIcon: _buildTimeCount(),
        addPrefixIconWidth: 50,
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
          Text(
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
    //       controller.resendOtpForgotPassword();
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
          controller.resendOtpForgotPassword();
        },
        isLoading: controller.isLoading,
        isDisabled: controller.otpTimeLeft.value != 0,
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      hideKeyboardWhenTouchOutside: true,
      appBar: CommonAppBar(
        titleType: AppBarTitle.none,
        // titleWidget: Text(
        //   l10n.forgot_password__title,
        //   style: AppTextStyles.s14w400.copyWith(color: AppColors.pacificBlue),
        // ),
        leadingIconColor: AppColors.pacificBlue,
        centerTitle: false,
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  _buildOtpInput(context),
                  // _buildTimeCount(),
                  // _buildSubmitBtn(),
                  _buildResendOtpBtn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
