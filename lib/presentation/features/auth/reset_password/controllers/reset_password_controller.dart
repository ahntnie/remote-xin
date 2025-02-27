import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../../repositories/all.dart';
import '../../../../../services/all.dart';
import '../../../../base/all.dart';
import '../../../../common_controller.dart/all.dart';
import '../../../../routing/routers/app_pages.dart';
import '../../login/controllers/login_controller.dart';
import '../../register/controllers/register_controller.dart';

class ResetPasswordController extends BaseController {
  ResetPasswordController({
    Key? key,
  });

  String otp = '';

  final AuthRepository _authService = Get.find();
  final appController = Get.find<AppController>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  var isDisableSubmitBtn = true.obs;
  var isShowPassword = true.obs;
  var isShowConfirmPassword = true.obs;
  var isValidator = false.obs;
  var is8Lenght = false.obs;

  void reset() {
    otp = '';
    passwordController.text = '';
    confirmPasswordController.text = '';

    isDisableSubmitBtn.value = true;
    isShowPassword.value = true;
    isShowConfirmPassword.value = true;
    isValidator.value = false;
    is8Lenght.value = false;
    update();
  }

  set setDisableSubmitBtn(bool value) {
    isDisableSubmitBtn.value = value;
    update();
  }

  void validatePassword(String password) {
    isValidator.value = ValidationUtil.isValidPassword(password);
    is8Lenght.value = password.trim().length > 7;
    update();
  }

  String? validateConfirmPassword(String? confirmPassword) {
    if (confirmPassword != passwordController.text) {
      return l10n.field__confirm_password_error_invalid;
    }

    return null;
  }

  final emailPattern = r'^.+@gmail\.com$';

  void submit() {
    if (isLoading) {
      return;
    }
    final loginController = Get.find<LoginController>();
    final emailOrPhoneValue = !loginController.isRegister.value
        ? RegExp(loginController.emailPattern)
                .hasMatch(loginController.emailController.text)
            ? loginController.emailController.text.trim()
            : loginController.phoneLogin.value
        : Get.find<RegisterController>().emailController.text.trim();

    final isFromForgotPassword = !loginController.isRegister.value;
    runAction(
      action: () async {
        final isPhone = !RegExp(emailPattern).hasMatch(emailOrPhoneValue);
        if (!isPhone) {
          await _authService.resetPassword(
            email: emailOrPhoneValue,
            otp: otp,
            password: passwordController.text,
            passwordConfirmation: confirmPasswordController.text,
          );

          final userId = await _authService.login(
            email: emailOrPhoneValue,
            password: passwordController.text,
          );

          await _onLoginSuccess(userId);
        } else {
          await _authService.resetPassword(
            phone: emailOrPhoneValue,
            otp: otp,
            password: passwordController.text,
            passwordConfirmation: confirmPasswordController.text,
          );

          final userId = await _authService.login(
            phone: emailOrPhoneValue,
            password: passwordController.text,
          );
          // appController.setLoggedUser(null);
          await _onLoginSuccess(userId);
        }
        // final userId = await _authService.login(
        //   email: email,
        //   password: passwordController.text,
        // );
        // // appController.setLoggedUser(null);
        // await _onLoginSuccess(userId);
        // return ViewUtil.showSuccessDialog(
        //   message: isFromForgotPassword
        //       ? l10n.set_password__success_message
        //       : l10n.create_account__success,
        //   buttonText: l10n.button__sign_in,
        //   barrierDismissible: false,
        //   onButtonPressed: () {
        //     Get.offAllNamed(Routes.login);
        //   },
        // );
      },
      onError: (exception) {
        if (exception is AuthException &&
            exception.kind == AuthExceptionKind.resetPasswordFail) {
          ViewUtil.showToast(
            title: isFromForgotPassword
                ? l10n.forgot_password__title
                : l10n.set_password__fail,
            message: l10n.error__password_reset_fail_message,
          );
        } else {
          ViewUtil.showToast(
            title: isFromForgotPassword
                ? l10n.forgot_password__title
                : l10n.set_password__fail,
            message: l10n.error__unknown,
          );
        }
      },
    );
  }

  Future<void> _onLoginSuccess(int userId) async {
    await Future.delayed(const Duration(seconds: 1));

    Get.find<NotificationBadgeCountService>();
    unawaited(Get.find<PushNotificationService>().initFirebaseMessaging());
    final UserRepository userRepo = Get.find();

    final User currentUser = await userRepo.getUserById(userId);
    Get.find<AppController>().setLoggedUser(currentUser);
    Get.find<AppController>().setLogged(true);

    await Get.find<ChatSocketService>().onInit();
    await Get.find<ChatSocketService>().connectSocket();

    if (currentUser.nickname != null && currentUser.nickname!.isNotEmpty) {
      unawaited(Get.offNamed(AppPages.afterAuthRoute));
    } else {
      unawaited(
        Get.offNamed(
          Routes.profile,
          arguments: {'isUpdateProfileFirstLogin': true},
        ),
      );
    }
  }
}
