import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:styled_text/styled_text.dart';

import '../../../../../core/all.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';
import '../../otp_receive/all.dart';
import '../../reset_password/all.dart';

class RegisterView extends BaseView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

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
            controller.setRegisterKind = RegisterKind.email;
            controller.emailFocus.requestFocus();
          } else {
            controller.setRegisterKind = RegisterKind.phone;
            controller.phoneFocus.requestFocus();
          }
        },
        currentValue: controller.registerKind.value == RegisterKind.email
            ? 'Email'
            : 'Phone',
      ),
    );
  }

  Widget _buildRegisterBtn() {
    return AppButton.primary(
      label: l10n.button__receive_otp,
      width: double.infinity,
      onPressed: controller.register,
      isLoading: controller.isLoading,
      isDisabled:
          controller.isDisableReceiveBtn.value || !controller.isAgree.value,
    );
  }

  // Widget _buildTextFieldPhone() {
  //   return Padding(
  //     padding: EdgeInsets.only(bottom: 28.h),
  //     child: AppTextField(
  //       focusNode: controller.phoneFocus,
  //       autofocus: true,
  //       textInputAction: TextInputAction.done,
  //       controller: controller.phoneController,
  //       hintText: l10n.field_phone__hint,
  //       hintStyle: AppTextStyles.s16w400.copyWith(
  //         color: AppColors.subText2,
  //         fontStyle: FontStyle.italic,
  //       ),
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

  // Widget _buildTextFieldEmail() {
  //   return Padding(
  //     padding: EdgeInsets.only(bottom: 28.h),
  //     child: Column(
  //       children: [
  //         AppTextField(
  //           focusNode: controller.emailFocus,
  //           inputFormatters: [LowerCaseTextFormatter()],
  //           autofocus: true,
  //           controller: controller.emailController,
  //           hintText: l10n.field_email__hint,
  //           hintStyle: AppTextStyles.s16w400.copyWith(
  //             color: AppColors.subText2,
  //             fontStyle: FontStyle.italic,
  //           ),
  //           label: l10n.field_email__label,
  //           textInputAction: TextInputAction.done,
  //           contentPadding: EdgeInsets.all(17.w),
  //           keyboardType: TextInputType.emailAddress,
  //           validator: controller.validateEmail,
  //           onChanged: (value) {
  //             controller.setDisableOtpReceiveBtn =
  //                 !controller.formKey.currentState!.validate();
  //           },
  //           autovalidateMode: AutovalidateMode.onUserInteraction,
  //         ),
  //         AppSpacing.gapH16,
  //         AppTextField(
  //           inputFormatters: [LowerCaseTextFormatter()],
  //           controller: controller.referralIdController,
  //           label: l10n.field__referralId,
  //           textInputAction: TextInputAction.done,
  //           contentPadding: EdgeInsets.all(17.w),
  //           keyboardType: TextInputType.text,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget buildPage(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return GestureDetector(
      onTap: () => ViewUtil.hideKeyboard(context),
      child: Container(
        padding: AppSpacing.edgeInsetsAll20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppIcon(
                  icon: AppIcons.close,
                  color: AppColors.text2,
                ).clickable(() {
                  Get.back();
                })
              ],
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPageFieldPhoneOrEmail(context),
                  const OtpReceiveView(),
                  SingleChildScrollView(
                    child: SizedBox(
                      height: isKeyboardVisible ? 1.sh : null,
                      child: const ResetPasswordView(),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageFieldPhoneOrEmail(BuildContext context) {
    return GestureDetector(
      onTap: () => ViewUtil.hideKeyboard(context),
      child: Container(
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.gapH20,
            Text(
              l10n.text_welcome_to_xintel,
              style: AppTextStyles.s26w700.toColor(AppColors.blue10),
            ),
            AppSpacing.gapH32,
            // _buildTextFieldEmail(),
            _buildTextFieldEmailOrPhone(),
            AppSpacing.gapH12,
            _buildTextFieldRefferralId(),
            AppSpacing.gapH12,
            _buildTermsAndConditionsCheckbox(),
            AppSpacing.gapH20,
            _buildnextPage(context),
            AppSpacing.gapH20,
            Row(
              children: [
                const Expanded(
                    child: Divider(
                  color: AppColors.subText3,
                )),
                Padding(
                  padding: AppSpacing.edgeInsetsH12,
                  child: Text(
                    l10n.label_or,
                    style: AppTextStyles.s14w700.text2Color
                        .copyWith(color: AppColors.subText3),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.subText3)),
              ],
            ),
            AppSpacing.gapH24,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildLoginGoogle(),
                if (Platform.isIOS) AppSpacing.gapW32,
                buildLoginApple(),
              ],
            ),
            AppSpacing.gapH24,
            _buildBtnChange()
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldEmail() {
    return AppTextField(
      // inputFormatters: [LowerCaseTextFormatter()],
      focusNode: controller.emailFocus,
      controller: controller.emailController,
      label: l10n.field_email__label,
      style: AppTextStyles.s16w400.text2Color,
      hintText: l10n.text_enter_email,
      hintStyle: AppTextStyles.s14w400.copyWith(
        color: AppColors.subText3,
      ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.grey8,
          )),
      textInputAction: TextInputAction.done,
      validator: (value) {
        // return null;

        // if (controller.validateEmail(value!)!.isNotEmpty) {
        //   return controller.validateEmail(value);
        // }

        return controller.validateEmail(value);
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        // if (controller
        //         .validatePassword(controller.passwordController.text)
        //         .isEmpty &&
        //     controller.validateEmail(value).isEmpty) {
        //   controller.setDisableLoginBtn = false;
        // }

        controller.setDisableOtpReceiveBtn = true;
      },
    );
  }

  Widget _buildTextFieldEmailOrPhone() {
    return Obx(() => controller.isPhone.value
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: Sizes.s8),
                child: SizedBox(
                  height: 24.h,
                  child: Text(
                    // l10n.text_email_or_phone_number,
                    l10n.field_email__label,
                    style: AppTextStyles.s16w500.text1Color
                        .copyWith(color: AppColors.text2),
                  ),
                ),
              ),
              AppSpacing.gapH4,
              InternationalPhoneNumberInput(
                autoFocus: true,
                initialValue:
                    PhoneNumber(isoCode: controller.initIsoCode.value),
                keyboardAction: TextInputAction.done,
                formatInput: false,
                cursorColor: Colors.black,
                textAlignVertical: TextAlignVertical.top,
                spaceBetweenSelectorAndTextField: 0,
                textFieldController: controller.emailController,
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
                  controller.setIsPhone(value.parseNumber());
                  // if (value.phoneNumber != null && value.phoneNumber!.isNotEmpty) {
                  //   controller.setDisableLoginBtn = false;
                  // }
                  // controller.phoneEdit.value = value.phoneNumber ?? '';

                  if (controller.initIsoCode.value != value.isoCode) {
                    controller.initIsoCode.value = value.isoCode ?? 'VN';
                    controller.phoneController.clear();
                  }

                  controller.phoneRegister.value = value.phoneNumber ?? '';

                  controller.setDisableOtpReceiveBtn = false;
                },
                // validator: (controller.currentUser.phone != null &&
                //         controller.currentUser.phone!.isNotEmpty)
                //     ? (value) {
                //         if (value != null && value.isEmpty) {
                //           return l10n.field_phone__error_invalid;
                //         }

                //         return null;
                //       }
                //     : null,
                // errorMessage: controller.phoneEdit.value.isNotEmpty &&
                //         controller.phoneEdit.value.replaceAll('+84', '').isNotEmpty
                //     ? l10n.field_phone__error_invalid
                //     : l10n.field_phone__error_empty,
                // autoValidateMode: controller.currentUser.phone != null &&
                //         controller.currentUser.phone!.isNotEmpty
                //     ? AutovalidateMode.disabled
                //     : AutovalidateMode.onUserInteraction,
                inputDecoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  // hintText: context.l10n.field_phone__label,
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
                    borderSide: BorderSide(color: AppColors.greyBorder),
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                ),
              ),
            ],
          )
        : AppTextField(
            // inputFormatters: [LowerCaseTextFormatter()],
            focusNode: controller.emailFocus,
            autofocus: true,
            controller: controller.emailController,
            // label: l10n.text_email_or_phone_number,
            label: l10n.field_email__label,
            style: AppTextStyles.s16w400.text2Color,
            // hintText: l10n.text_enter_email_or_phone_number,
            hintText: l10n.field_email__hint,
            hintStyle: AppTextStyles.s14w400.copyWith(
              color: AppColors.subText3,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.grey8,
                )),
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (controller.validateEmail(value!).isNotEmpty) {
                return controller.validateEmail(value);
              }

              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              controller.setIsPhone(value);
              // if (controller
              //         .validatePassword(controller.passwordController.text)
              //         .isEmpty &&
              //     controller.validateEmail(value).isEmpty) {
              //   controller.setDisableLoginBtn = false;
              // }
              controller.phoneRegister.value = value;

              if (controller.validateEmail(value).isNotEmpty) {
                controller.setDisableOtpReceiveBtn = true;
              } else {
                controller.setDisableOtpReceiveBtn = false;
              }
            },
          ));
  }

  Widget _buildTextFieldRefferralId() {
    return AppTextField(
      // inputFormatters: [LowerCaseTextFormatter()],
      controller: controller.referralIdController,
      label: l10n.text_referral_id,
      isSponsor: true,
      textInputAction: TextInputAction.done,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.grey8,
          )),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildnextPage(BuildContext context) {
    return Obx(
      () => AppButton.primary(
        label: l10n.button__continue,
        width: double.infinity,
        onPressed: () {
          // if (user != null &&
          //     ValidationUtil.isValidEmail(user.loginLocal ?? '')) {
          //   controller.loginKind.value = LoginKind.email;
          //   controller.emailController.text = user.email ?? '';
          // } else if (user != null &&
          //     !ValidationUtil.isValidEmail(user.loginLocal ?? '')) {
          //   controller.loginKind.value = LoginKind.phone;
          //   controller.phoneLogin.value = user.phone ?? '';
          // }

          // controller.login();
          FocusScope.of(context).unfocus();
          // controller.nextPage();
          controller.register();
        },
        isLoading: controller.isLoading,
        isDisabled:
            controller.isDisableReceiveBtn.value || !controller.isAgree.value,
      ),
    );
  }

  Widget buildLoginGoogle() {
    return Container(
      padding: AppSpacing.edgeInsetsAll12,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ]),
      child: AppIcon(
        icon: AppIcons.google,
        size: Sizes.s28,
      ).clickable(() {
        Get.find<LoginController>().signInWithGoogle();
      }),
    );
  }

  Widget buildLoginApple() {
    // return (Platform.isIOS && controller.isAppleSignInAvailable.value)
    return Platform.isIOS
        ? Container(
            padding: AppSpacing.edgeInsetsAll12,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ]),
            child: AppIcon(
              icon: AppIcons.apple,
              size: Sizes.s28,
            ),
          ).clickable(() {
            Get.find<LoginController>().signInWithApple();
          })
        : const SizedBox();
  }

  Widget _buildBtnChange() {
    return Center(
      child: Text(
        l10n.text_log_in_existing_account,
        style: AppTextStyles.s18w600.copyWith(color: AppColors.blue10),
      ),
    ).clickable(() {
      Get.find<LoginController>().isRegister.value = false;
    });
  }

  Widget _buildTextFieldPhone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Sizes.s16),
          child: SizedBox(
            height: 24.h,
            child: Text(
              l10n.field_phone__label,
              style: AppTextStyles.s16w400.text1Color,
            ),
          ),
        ),
        AppSpacing.gapH4,
        InternationalPhoneNumberInput(
          initialValue: PhoneNumber(isoCode: controller.initIsoCode.value),
          keyboardAction: TextInputAction.done,
          formatInput: false,
          textAlignVertical: TextAlignVertical.top,
          spaceBetweenSelectorAndTextField: 0,
          textFieldController: controller.phoneController,
          focusNode: controller.phoneFocus,
          selectorConfig: const SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            leadingPadding: Sizes.s12,
            useBottomSheetSafeArea: true,
            setSelectorButtonAsPrefixIcon: true,
            trailingSpace: false,
          ),
          selectorTextStyle: AppTextStyles.s16w400.text1Color,
          textStyle: AppTextStyles.s16w400.text1Color,
          onInputChanged: (value) {
            controller.setDisableOtpReceiveBtn =
                !value.parseNumber().isNotEmpty;

            controller.phoneRegister.value = value.phoneNumber ?? '';

            if (controller.initIsoCode.value != value.isoCode) {
              controller.initIsoCode.value = value.isoCode ?? 'VN';
              controller.phoneController.clear();
            }
          },
          // validator: (value) {
          // if (value != null && value.isEmpty) {
          //   return l10n.field_phone__error_invalid;
          // }
          // },
          errorMessage: l10n.field_phone__error_invalid,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          inputDecoration: InputDecoration(
            fillColor: AppColors.fieldBackground,
            filled: true,
            hintText: l10n.field_phone__hint,
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            hintStyle: AppTextStyles.s16w400.subText1Color,
            errorStyle: AppTextStyles.s14Base.negativeColor,
            errorMaxLines: 2,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
          ),
        ),
      ],
    ).paddingOnly(bottom: Sizes.s16);
  }

  Widget _buildTermsAndConditionsCheckbox() {
    return Padding(
      padding: AppSpacing.edgeInsetsOnlyBottom16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Obx(
          //   () => Checkbox(
          //     value: controller.isAgree.value,
          //     onChanged: (_) => controller.isAgree.toggle(),
          //     activeColor: AppColors.pacificBlue,
          //     checkColor: AppColors.white,
          //   ),
          // ),
          Obx(() => Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: controller.isAgree.value
                            ? AppColors.blue1
                            : AppColors.subText2),
                    borderRadius: BorderRadius.circular(4),
                    color: controller.isAgree.value
                        ? AppColors.blue10
                        : AppColors.white),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 18,
                ),
              )).clickable(() {
            controller.isAgree.toggle();
          }),
          AppSpacing.gapW12,
          Expanded(
            child: StyledText(
              // text: l10n.register__terms_and_conditions,
              text: l10n.text_create_account_agreement,
              style: AppTextStyles.s16w500.subText2Color,
              tags: {
                'terms': StyledTextActionTag(
                  (_, __) =>
                      IntentUtils.openBrowserURL(url: AppConstants.termURL),
                  style: AppTextStyles.s16w500.copyWith(
                    color: AppColors.blue10,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.blue10,
                  ),
                ),
                'conditions': StyledTextActionTag(
                  (_, __) =>
                      IntentUtils.openBrowserURL(url: AppConstants.policyURL),
                  style: AppTextStyles.s16w500.copyWith(
                    color: AppColors.blue10,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.blue10,
                  ),
                ),
              },
            ).clickable(() {
              controller.isAgree.toggle();
            }),
          ),
        ],
      ),
    );
  }
}
