import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../repositories/all.dart';
import '../../../../base/all.dart';
import '../../../../routing/routers/app_pages.dart';

enum ForgotSendKind {
  email,
  phone,
}

class ForgotPasswordController extends BaseController {
  final AuthRepository _authService = Get.find();

  final formKey = GlobalKey<FormState>();
  var selectKind = ForgotSendKind.email.obs;
  var isDisableReceiveBtn = true.obs;

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  FocusNode phoneFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  RxString phoneForgot = ''.obs;
  RxString initIsoCode = 'VN'.obs;

  set setDisableOtpReceiveBtn(bool value) {
    isDisableReceiveBtn.value = value;
    update();
  }

  set setForgotSendKind(ForgotSendKind kind) {
    selectKind.value = kind;
    if (kind == ForgotSendKind.email) {
      final mess = validateEmail(emailController.text);
      setDisableOtpReceiveBtn = mess != null;
    } else {
      final mess = validatePhone(phoneController.text);
      setDisableOtpReceiveBtn = mess != null;
    }
    update();
  }

  String? validateEmail(String? email) {
    if (!ValidationUtil.isEmptyEmail(email!)) {
      return l10n.field_email__error_empty;
    }

    if (!ValidationUtil.isValidEmail(email)) {
      return l10n.field_email__error_invalid;
    }

    return null;
  }

  String? validatePhone(String? phone) {
    if (!ValidationUtil.isEmptyPhoneNumber(phone!)) {
      return l10n.field_phone__error_empty;
    }

    if (!ValidationUtil.isValidPhoneNumber(phone)) {
      return l10n.field_phone__error_invalid;
    }

    return null;
  }

  Future<void> resetPassword() async {
    if (isLoading) {
      return;
    }
    if (selectKind.value == ForgotSendKind.email) {
      if (formKey.currentState!.validate()) {
        await runAction(
          action: () async {
            await _authService.requestResetPassword(
              email: emailController.text,
            );
            await Get.toNamed(Routes.otpReceiveForgotPassword, arguments: {
              'email': emailController.text,
              'flowFrom': Routes.forgotPassword,
            });
          },
          onError: (exception) {
            if (exception is AuthException) {
              if (exception.kind == AuthExceptionKind.userNotFound) {
                ViewUtil.showToast(
                  title: l10n.forgot_password__title,
                  message: l10n.error__user_not_found,
                );
              } else if (exception.kind == AuthExceptionKind.limitOtp) {
                ViewUtil.showToast(
                  title: l10n.forgot_password__title,
                  message: l10n.error__limit_otp,
                );
              }
            } else {
              ViewUtil.showToast(
                title: l10n.forgot_password__title,
                message: l10n.error__unknown,
              );
            }
          },
        );
      }
    }
    if (selectKind.value == ForgotSendKind.phone) {
      if (formKey.currentState!.validate()) {
        await runAction(
          action: () async {
            await _authService.requestResetPassword(
              phone: phoneForgot.value,
            );
            await Get.toNamed(Routes.otpReceiveForgotPassword, arguments: {
              'phone': phoneForgot.value.removeAllWhitespace,
              'flowFrom': Routes.forgotPassword,
            });
          },
          onError: (exception) {
            if (exception is AuthException) {
              if (exception.kind == AuthExceptionKind.userNotFound) {
                ViewUtil.showToast(
                  title: l10n.forgot_password__title,
                  message: l10n.error__user_not_found,
                );
              }
            } else {
              ViewUtil.showToast(
                title: l10n.forgot_password__title,
                message: l10n.error__unknown,
              );
            }
          },
        );
      }
    }
  }
}
