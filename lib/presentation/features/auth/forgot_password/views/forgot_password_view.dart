import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../../core/all.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/styles/styles.dart';
import '../../../all.dart';

class ForgotPasswordView extends BaseView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  Widget _buildEmailOrPhoneInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: SwitchButton(
        values: const ['Email', 'Phone'],
        buttonPadding: EdgeInsets.symmetric(
          horizontal: 28.w,
          vertical: 10.h,
        ),
        onChange: (value) {
          ViewUtil.hideKeyboard(Get.context!);
          if (value == 'Email') {
            controller.setForgotSendKind = ForgotSendKind.email;
            controller.emailFocus.requestFocus();
          } else {
            controller.setForgotSendKind = ForgotSendKind.phone;
            controller.phoneFocus.requestFocus();
          }
        },
        currentValue: controller.selectKind.value == ForgotSendKind.email
            ? 'Email'
            : 'Phone',
      ),
    );
  }

  Widget _buildSubmitBtn() {
    return AppButton.primary(
      label: l10n.forgot_password__button_title,
      width: double.infinity,
      onPressed: controller.resetPassword,
      isLoading: controller.isLoading,
      isDisabled: controller.isDisableReceiveBtn.value,
    );
  }

  // Widget _buildTextFieldPhone() {
  //   return Padding(
  //     padding: EdgeInsets.only(bottom: 28.h),
  //     child: AppTextField(
  //       autofocus: true,
  //       controller: controller.phoneController,
  //       hintText: l10n.field_phone__hint,
  //       label: l10n.field_phone__label,
  //       contentPadding: EdgeInsets.all(17.w),
  //       keyboardType: TextInputType.phone,
  //       validator: controller.validatePhone,
  //       onChanged: (value) {
  //         controller.setDisableOtpReceiveBtn =
  //             !controller.formKey.currentState!.validate();
  //       },
  //       autovalidateMode: AutovalidateMode.onUserInteraction,
  //     ),
  //   );
  // }

  Widget _buildTextFieldPhone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sizes.s8),
          child: SizedBox(
            height: 24.h,
            child: Text(
              l10n.field_phone__label,
              style: AppTextStyles.s16w400.text1Color
                  .copyWith(color: AppColors.pacificBlue),
            ),
          ),
        ),
        AppSpacing.gapH4,
        InternationalPhoneNumberInput(
          initialValue: PhoneNumber(isoCode: controller.initIsoCode.value),
          keyboardAction: TextInputAction.done,
          textAlignVertical: TextAlignVertical.top,
          spaceBetweenSelectorAndTextField: 0,
          textFieldController: controller.phoneController,
          focusNode: controller.phoneFocus,
          formatInput: false,
          selectorConfig: const SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            leadingPadding: Sizes.s12,
            useBottomSheetSafeArea: true,
            setSelectorButtonAsPrefixIcon: true,
            trailingSpace: false,
          ),

          selectorTextStyle: AppTextStyles.s16w400.text2Color,
          textStyle: AppTextStyles.s16w400.text2Color,
          onInputChanged: (value) {
            controller.setDisableOtpReceiveBtn =
                !value.parseNumber().isNotEmpty;

            controller.phoneForgot.value = value.phoneNumber ?? '';

            if (controller.initIsoCode.value != value.isoCode) {
              controller.initIsoCode.value = value.isoCode ?? 'VN';
              controller.phoneController.clear();
            }
          },
          // validator: (value) {
          //   if (value != null && value.isEmpty) {
          //     return l10n.field_phone__error_invalid;
          //   }
          //   return null;
          // },
          errorMessage: l10n.field_phone__error_invalid,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          inputDecoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: l10n.field_phone__hint,
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            hintStyle: AppTextStyles.s16w400.copyWith(
              color: AppColors.subText2,
              fontStyle: FontStyle.italic,
            ),
            errorStyle: AppTextStyles.s14Base.negativeColor,
            errorMaxLines: 2,
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyBorder),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyBorder),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyBorder),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyBorder),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
          ),
        ),
      ],
    ).paddingOnly(bottom: Sizes.s16);
  }

  Widget _buildTextFieldEmail() {
    return Padding(
      padding: EdgeInsets.only(bottom: 28.h),
      child: AppTextField(
        autofocus: true,
        // inputFormatters: [LowerCaseTextFormatter()],
        controller: controller.emailController,
        hintText: l10n.field_email__hint,
        hintStyle: AppTextStyles.s16w400.copyWith(
          color: AppColors.subText2,
          fontStyle: FontStyle.italic,
        ),
        label: l10n.field_email__label,
        textInputAction: TextInputAction.done,
        contentPadding: EdgeInsets.all(17.w),
        keyboardType: TextInputType.emailAddress,
        validator: controller.validateEmail,
        onChanged: (value) {
          controller.setDisableOtpReceiveBtn =
              !controller.formKey.currentState!.validate();
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      hideKeyboardWhenTouchOutside: true,
      appBar: CommonAppBar(
        titleType: AppBarTitle.none,
        titleWidget: Text(
          l10n.forgot_password__title,
          style: AppTextStyles.s14w500.copyWith(color: AppColors.pacificBlue),
        ),
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
                  _buildEmailOrPhoneInput(),
                  controller.selectKind.value == ForgotSendKind.email
                      ? _buildTextFieldEmail()
                      : _buildTextFieldPhone(),
                  _buildSubmitBtn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
