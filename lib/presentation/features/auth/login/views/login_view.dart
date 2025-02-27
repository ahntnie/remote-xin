import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';
import '../../otp_receive/all.dart';
import '../../reset_password/all.dart';

class LoginView extends BaseView<LoginController> {
  const LoginView({Key? key}) : super(key: key);
  @override
  Widget buildPage(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return PopScope(
      onPopInvoked: (didPop) {
        controller.emailController.clear();
        controller.passwordController.clear();
        controller.isRegister.value = false;
        controller.phoneLogin.value = '';
        controller.currentPage.value = 0;
        controller.isPhone.value = false;
        controller.phoneController.clear();
      },
      child: Obx(() => controller.isRegister.value
          ? const RegisterView()
          : GestureDetector(
              onTap: () => ViewUtil.hideKeyboard(context),
              child: Container(
                padding: AppSpacing.edgeInsetsAll20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Obx(
                      () => Row(
                        mainAxisAlignment: controller.currentPage.value > 0
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.end,
                        children: [
                          if (controller.currentPage > 0)
                            AppIcon(
                              icon: AppIcons.arrowLeft,
                              color: AppColors.text2,
                              onTap: () {
                                controller.previousPage();
                              },
                            ),
                          AppIcon(
                            icon: AppIcons.close,
                            color: AppColors.text2,
                          ).clickable(() {
                            Get.back();
                          })
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: controller.pageControllerLogin,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildPageFieldPhoneOrEmail(context),
                          _buildPagePassword(),
                          _buildPageForgotPassword(),
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
            )),
    );
  }

  Widget _buildPageFieldPhoneOrEmail(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ViewUtil.hideKeyboard(context);
      },
      child: Container(
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.gapH20,
            Text(
              l10n.text_login,
              style: AppTextStyles.s26w700.toColor(AppColors.blue10),
            ),
            AppSpacing.gapH32,
            _buildTextFieldEmailOrPhone(),
            AppSpacing.gapH32,
            _buildnextPage('email'),
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
                buildLoginGoogle(context),
                if (Platform.isIOS && controller.isAppleSignInAvailable.value)
                  AppSpacing.gapW32,
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

  String hideEmail(String email) {
    final int indexOfAt = email.indexOf('@');
    if (indexOfAt <= 3) {
      return email; // Không xử lý nếu email quá ngắn
    }
    final String firstThreeChars = email.substring(0, 3);
    final String domain = email.substring(indexOfAt);
    return '$firstThreeChars******$domain';
  }

  String hidePhoneNumber(String phoneNumber) {
    if (phoneNumber.length <= 5) {
      return phoneNumber; // Không xử lý nếu số điện thoại quá ngắn
    }
    final String firstFiveChars = phoneNumber.substring(0, 6);
    return '$firstFiveChars******';
  }

  Widget _buildPagePassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.gapH20,
        Text(
          l10n.text_enter_password,
          style: AppTextStyles.s26w700.toColor(AppColors.blue10),
        ),
        Obx(
          () => Text(
            RegExp(controller.emailPattern)
                    .hasMatch(controller.phoneLogin.value)
                ? hideEmail(controller.phoneLogin.value)
                : hidePhoneNumber(controller.phoneLogin.value),
            style: AppTextStyles.s14w500.toColor(AppColors.grey8),
          ),
        ),
        AppSpacing.gapH32,
        _buildTextFieldPassword(),
        AppSpacing.gapH32,
        Obx(
          () => _buildLoginBtn(null),
        ),
        AppSpacing.gapH24,
        _buildForgotPassword()
      ],
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
                    l10n.text_email_or_phone_number,
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

                  controller.phoneLogin.value = value.phoneNumber ?? '';
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
            label: l10n.text_email_or_phone_number,
            style: AppTextStyles.s16w400.text2Color,
            hintText: l10n.text_enter_email_or_phone_number,
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
              controller.phoneLogin.value = value;
            },
          ));
  }

  Widget _buildnextPage(String type) {
    return AppButton.primary(
      label: l10n.button__continue,
      width: double.infinity,
      onPressed: () async {
        LogUtil.e('herere $type');
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
        if (type == 'email') {
          controller.emailFocus.unfocus();
          controller.passFocus.requestFocus();
        }
        if (type == 'pass') {
          controller.passFocus.unfocus();
        }
        if (type == 'send_otp') {
          try {
            controller.resendOtpForgotPassword();
          } catch (e) {
            LogUtil.e(e);
          }
        }

        controller.nextPage();

        // final x = PhoneNumber.parse('84945884115');
        // log(x.toString());
        // final x = PhoneNumberUtil.formatPhoneNumber('84945884115');
        // log(x.toString());
      },
      isLoading: controller.isLoading,
      // isDisabled: controller.isDisableLoginBtn.value,
    );
  }

  Widget _buildLoginBtn(User? user) {
    return AppButton.primary(
      label: l10n.button__sign_in,
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

        controller.login();
      },
      isLoading: controller.isLoading,
      isDisabled: controller.isDisableLoginBtn.value,
    );
  }

  Widget buildLoginGoogle(BuildContext context) {
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
        controller.signInWithGoogle();
        ViewUtil.hideKeyboard(context);
      }),
    );
  }

  Widget buildLoginApple() {
    // return (Platform.isIOS && controller.isAppleSignInAvailable.value)
    return (Platform.isIOS && controller.isAppleSignInAvailable.value)
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
            controller.signInWithApple();
          })
        : const SizedBox();
  }

  Widget _buildBtnChange() {
    return Center(
      child: Text(
        l10n.text_create_account_xintel,
        style: AppTextStyles.s18w600.copyWith(color: AppColors.blue10),
      ),
    ).clickable(() {
      controller.isRegister.value = true;
    });
  }

  Widget _buildForgotPassword() {
    return Center(
      child: Text(
        l10n.forgot_password__title,
        style: AppTextStyles.s18w600.copyWith(color: AppColors.blue10),
      ),
    ).clickable(() {
      controller.nextPage();
      controller.passFocus.unfocus();
    });
  }

  Widget _buildPageForgotPassword() {
    return Column(
      children: [
        SizedBox(
          height: 0.07.sh,
        ),
        Assets.images.forgotPassword.image(scale: 2),
        Text(
          l10n.text_enter_password,
          style: AppTextStyles.s26w700.toColor(AppColors.blue10),
        ),
        Obx(
          () => Text(
            RegExp(controller.emailPattern)
                    .hasMatch(controller.phoneLogin.value)
                ? hideEmail(controller.phoneLogin.value)
                : hidePhoneNumber(controller.phoneLogin.value),
            style: AppTextStyles.s16w500.toColor(AppColors.text2),
          ),
        ),
        AppSpacing.gapH12,
        Text(
          l10n.text_protect_account,
          style: AppTextStyles.s16w500.subText2Color,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        _buildnextPage('send_otp')
      ],
    );
  }

  Widget _buildTextFieldPassword() {
    return Obx(() => AppTextField(
          controller: controller.passwordController,
          label: l10n.field__password_label,
          textInputAction: TextInputAction.done,
          focusNode: controller.passFocus,
          obscureText: controller.isHidePassword.value,
          suffixIcon: AppIcon(
            icon: controller.isHidePassword.value
                ? AppIcons.eyeClose
                : AppIcons.eyeOpen,
            color: AppColors.grey8,
          ),
          hintText: l10n.text_enter_password,
          hintStyle: AppTextStyles.s14w400.copyWith(
            color: AppColors.subText3,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.grey8,
              )),
          onSuffixIconPressed: () {
            controller.isHidePassword.toggle();
          },
          validator: (value) {
            if (controller.validatePassword(value!).isNotEmpty) {
              return controller.validatePassword(value);
            }

            return null;
          },
          onChanged: (value) {
            controller.setDisableLoginBtn = true;
            if (controller.appController.lastLoggedUser != null &&
                controller.validatePassword(value).isEmpty) {
              controller.setDisableLoginBtn = false;
            } else if (controller.validatePassword(value).isEmpty &&
                (controller.isPhone.value ||
                    (controller
                            .validateEmail(controller.emailController.text)
                            .isEmpty ||
                        controller.phoneController.text.isNotEmpty))) {
              controller.setDisableLoginBtn = false;
            }
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ));
  }
}
