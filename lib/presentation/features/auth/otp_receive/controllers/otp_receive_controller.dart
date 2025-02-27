import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../repositories/all.dart';
import '../../../../base/all.dart';
import '../../../all.dart';
import '../../reset_password/all.dart';

class OtpReceiveController extends BaseController {
  final AuthRepository _authService = Get.find();

  // final String? email = Get.arguments['email'] as String?;
  // final flowFrom = Get.arguments['flowFrom'] as String;
  // final String? phone = Get.arguments['phone'] as String?;

  final formKey = GlobalKey<FormState>();
  var isDisableSubmitBtn = true.obs;
  var otpTimeLeft = DurationConstants.maxTimeLiveOTP.inSeconds.obs;
  // late Timer timer;

  final otpController = TextEditingController();
  late CountdownTimer _countdownTimer;
  bool isTimerRunning = false;

  void reset() {
    isDisableSubmitBtn.value = true;
    otpController.text = '';
    otpTimeLeft.value = 0;
    isTimerRunning = false;
    try {
      _countdownTimer.stop(); // Dừng countdownTimer hiện tại
    } catch (e) {
      LogUtil.e(e);
    }
    update();
  }

  @override
  void onInit() {
    startOtpTimer();
    super.onInit();
  }

  set setDisableSubmitBtn(bool value) {
    isDisableSubmitBtn.value = value;
    update();
  }

  String? validateOtp(String? otp) {
    if (otp!.isEmpty) {
      return l10n.field_otp__error_empty;
    }

    if (otp.length != 6) {
      return l10n.field_otp__error_invalid;
    }

    return null;
  }

  void startOtpTimer() {
    otpTimeLeft.value = DurationConstants.maxTimeLiveOTP.inSeconds;

    // timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   if (otpTimeLeft.value > 0) {
    //     otpTimeLeft.value--;
    //   } else {
    //     timer.cancel();
    //   }
    // });

    _countdownTimer = CountdownTimer(
      seconds: otpTimeLeft.value,
      onTick: (value) {
        isTimerRunning = true;
        otpTimeLeft.value = value;
      },
      onFinished: () {
        isTimerRunning = false;
        _countdownTimer.stop();
      },
    );

    SystemChannels.lifecycle.setMessageHandler((msg) {
// On AppLifecycleState: paused
      if (msg == AppLifecycleState.paused.toString()) {
        if (isTimerRunning) {
          _countdownTimer.pause(otpTimeLeft.value); //setting end time on pause
        }
      }

// On AppLifecycleState: resumed
      if (msg == AppLifecycleState.resumed.toString()) {
        if (isTimerRunning) {
          _countdownTimer.resume();
        }
      }

      return Future(() => null);
    });

    isTimerRunning = true;
    _countdownTimer.start();
  }

  final emailPattern = r'^.+@gmail\.com$';

  void submit() {
    if (isLoading) {
      return;
    }
    runAction(
      handleLoading: false,
      action: () async {
        final loginController = Get.find<LoginController>();
        final emailOrPhoneValue = !loginController.isRegister.value
            ? RegExp(loginController.emailPattern)
                    .hasMatch(loginController.emailController.text)
                ? loginController.emailController.text.trim()
                : loginController.phoneLogin.value
            : Get.find<RegisterController>().emailController.text.trim();
        final isPhone = !RegExp(emailPattern).hasMatch(emailOrPhoneValue);
        if (!isPhone) {
          final resp = await _authService.validateOtp(
            email: emailOrPhoneValue,
            otp: otpController.text,
          );
          if (resp != null) {
            Get.find<ResetPasswordController>().otp = otpController.text;

            if (loginController.isRegister.value) {
              Get.find<RegisterController>().nextPage();
            } else {
              Get.find<LoginController>().nextPage();
            }
          }
        } else {
          final resp = await _authService.validateOtp(
            phone: emailOrPhoneValue,
            otp: otpController.text,
          );
          if (resp != null) {
            // await Get.offNamed(Routes.resetPassword, arguments: {
            //   'phone': phone,
            //   'otp': otpController.text,
            //   'flowFrom': flowFrom,
            // });

            Get.find<ResetPasswordController>().otp = otpController.text;

            if (loginController.isRegister.value) {
              Get.find<RegisterController>().nextPage();
            } else {
              Get.find<LoginController>().nextPage();
            }
          }
        }
      },
      onError: (exception) {
        otpController.clear();
        if (exception is AuthException) {
          if (exception.kind == AuthExceptionKind.otpIncorrect) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.error__otp_incorrect,
            );
          } else if (exception.kind == AuthExceptionKind.otpNotExpired) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.otp__not_expired,
            );
          } else if (exception.kind == AuthExceptionKind.userNotFound) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.error__user_not_found,
            );
          } else if (exception.kind == AuthExceptionKind.custom) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: exception.exception.toString(),
            );
          }
        } else {
          ViewUtil.showToast(
            title: l10n.otp__title,
            message: l10n.error__unknown,
          );
        }
      },
    );
  }

  Future<void> resendOtpRegister() async {
    if (isLoading) {
      return;
    }
    if (otpTimeLeft.value > 0) {
      return;
    }
    await runAction(
      action: () async {
        final loginController = Get.find<LoginController>();
        final emailOrPhoneValue = !loginController.isRegister.value
            ? loginController.emailController.text.trim()
            : Get.find<RegisterController>().emailController.text.trim();
        final isPhone = !RegExp(emailPattern).hasMatch(emailOrPhoneValue);
        if (!isPhone) {
          final String? code = await _authService.requestResendOTP(
            email: emailOrPhoneValue,
            type: 'register',
          );

          if (code != null) {
            startOtpTimer();
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.otp__resend_success,
            );
          }
        } else {
          final String? code = await _authService.requestResendOTP(
            phone: emailOrPhoneValue,
            type: 'register',
          );

          if (code != null) {
            startOtpTimer();
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.otp__resend_success,
            );
          }
        }
      },
      onError: (exception) {
        if (exception is AuthException) {
          if (exception.kind == AuthExceptionKind.userNotFound) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.error__user_not_found,
            );
          } else if (exception.kind == AuthExceptionKind.custom) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.error__unknown,
            );
          } else if (exception.kind == AuthExceptionKind.limitOtp) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.error__limit_otp,
            );
          }
        } else {
          ViewUtil.showToast(
            title: l10n.otp__title,
            message: l10n.error__unknown,
          );
        }
      },
    );
  }

  Future<void> resendOtpForgotPassword() async {
    if (isLoading) {
      return;
    }
    if (otpTimeLeft.value > 0) {
      return;
    }
    await runAction(
      action: () async {
        final loginController = Get.find<LoginController>();
        final emailOrPhoneValue = !loginController.isRegister.value
            ? loginController.emailController.text.trim()
            : Get.find<RegisterController>().emailController.text.trim();
        final isPhone = !RegExp(emailPattern).hasMatch(emailOrPhoneValue);
        if (!isPhone) {
          final String? code = await _authService.requestResendOTP(
            email: emailOrPhoneValue,
            type: 'reset-password',
          );

          if (code != null) {
            startOtpTimer();
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.otp__resend_success,
            );
          }
        } else {
          final String? code = await _authService.requestResendOTP(
            phone: emailOrPhoneValue,
            type: 'reset-password',
          );

          if (code != null) {
            startOtpTimer();
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.otp__resend_success,
            );
          }
        }
      },
      onError: (exception) {
        if (exception is AuthException) {
          if (exception.kind == AuthExceptionKind.userNotFound) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.error__user_not_found,
            );
          } else if (exception.kind == AuthExceptionKind.custom) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.error__unknown,
            );
          } else if (exception.kind == AuthExceptionKind.limitOtp) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.error__limit_otp,
            );
          }
        } else {
          ViewUtil.showToast(
            title: l10n.otp__title,
            message: l10n.error__unknown,
          );
        }
      },
    );
  }

  @override
  void onClose() {
    // timer.cancel();
    super.onClose();
  }
}
