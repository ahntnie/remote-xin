import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../repositories/all.dart';
import '../../../../base/all.dart';
import '../../otp_receive/controllers/otp_receive_controller.dart';

enum RegisterKind {
  email,
  phone,
}

class RegisterController extends BaseController {
  final AuthRepository _authService = Get.find();

  final formKey = GlobalKey<FormState>();
  var registerKind = RegisterKind.email.obs;
  var isDisableReceiveBtn = true.obs;

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final referralIdController = TextEditingController();
  FocusNode phoneFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  RxString phoneRegister = ''.obs;
  RxString initIsoCode = 'VN'.obs;

  RxBool isAgree = false.obs;
  final PageController pageController = PageController();
  RxInt currentPage = 0.obs;

  int userId = 0;

  RxBool isRegister = false.obs;
  RxBool isPhone = false.obs;

  final phonePattern = r'^[0-9]+$';
  final emailPattern = r'^.+@gmail\.com$';

  void reset() {
    registerKind.value = RegisterKind.email;
    isDisableReceiveBtn.value = true;
    emailController.text = '';
    phoneController.text = '';
    phoneRegister.value = '';
    isAgree.value = false;
    currentPage.value = 0;
    isRegister.value = false;
    isPhone.value = false;
    update();
  }

  void setIsPhone(String value) {
    if (isPhone.value == true) {
      if (RegExp(phonePattern).hasMatch(value) && value.length > 2) {
        isPhone.value = true;
      } else {
        isPhone.value = false;
      }
    } else {
      if (RegExp(phonePattern).hasMatch(value) && value.length > 8) {
        isPhone.value = true;
      } else {
        isPhone.value = false;
      }
    }
    if (isPhone.value == true) {
      Future.delayed(const Duration(seconds: 1), () {
        if (isPhone.value) {
          isDisableReceiveBtn.value = false;
          update();
        }
      });
    }
    update();
  }

  set setDisableOtpReceiveBtn(bool value) {
    isDisableReceiveBtn.value = value;
    update();
  }

  set setRegisterKind(RegisterKind kind) {
    registerKind.value = kind;
    if (kind == RegisterKind.email) {
      final mess = validateEmail(emailController.text);
      setDisableOtpReceiveBtn = mess != null;
    } else {
      final mess = validatePhone(phoneController.text);
      setDisableOtpReceiveBtn = mess != null;
    }
    update();
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    currentPage++;
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    currentPage--;
  }

  String validateEmail(String? email) {
    if (!ValidationUtil.isEmptyEmail(email!)) {
      return l10n.field_email__error_empty;
    }

    if (!ValidationUtil.isValidEmail(email)) {
      return l10n.field_email__error_invalid;
    }

    return '';
  }

  String? validatePhone(String? phone) {
    if (!ValidationUtil.isEmptyPhoneNumber(phone!)) {
      return l10n.field_phone__error_empty;
    }

    // if (!ValidationUtil.isValidPhoneNumber(phone)) {
    //   return l10n.field_phone__error_invalid;
    // }

    return null;
  }

  Future<void> register() async {
    if (isLoading) {
      return;
    }
    RegisterKind registerKindValue;
    if (RegExp(emailPattern).hasMatch(emailController.text)) {
      registerKindValue = RegisterKind.email;
    } else {
      registerKindValue = RegisterKind.phone;
    }

    if (registerKindValue == RegisterKind.email) {
      await runAction(
        action: () async {
          final user = await _authService.register(
            email: emailController.text.trim(),
            referralId: referralIdController.text.trim(),
          );
          // await Get.toNamed(Routes.otpReceive, arguments: {
          //   'email': emailController.text,
          //   'flowFrom': Routes.register,
          // });
          userId = user.id;

          nextPage();

          try {
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.find<OtpReceiveController>().startOtpTimer();
            });
          } catch (e) {
            LogUtil.e(e);
          }
        },
        onError: (exception) {
          if (exception is AuthException) {
            if (exception.kind == AuthExceptionKind.emailAlreadyInUse ||
                exception.kind == AuthExceptionKind.phoneAlreadyInUse) {
              // nextPage();
              ViewUtil.showToast(
                title: l10n.register__title,
                message: l10n.error__email_already_in_use,
              );
            } else if (exception.kind == AuthExceptionKind.custom) {
              final ServerError errors = exception.exception as ServerError;
              if (errors.fieldErrors.isNotEmpty) {
                for (var error in errors.fieldErrors) {
                  if (error.field == 'email') {
                    ViewUtil.showToast(
                      title: l10n.register__title,
                      message: error.messages.first,
                    );
                  } else if (error.field == 'ref_id') {
                    ViewUtil.showToast(
                      title: l10n.register__title,
                      message: error.messages.first,
                    );
                  }
                }
              }
            }
          } else {
            ViewUtil.showToast(
              title: l10n.register__title,
              message: l10n.error__unknown,
            );
          }
        },
      );
    }
    if (registerKindValue == RegisterKind.phone) {
      // if (formKey.currentState!.validate()) {
      // }
      await runAction(
        action: () async {
          final user = await _authService.register(
            phone: phoneRegister.value,
            referralId: referralIdController.text,
          );
          // await Get.toNamed(Routes.otpReceive, arguments: {
          //   'phone': phoneRegister.value.removeAllWhitespace,
          //   'flowFrom': Routes.register,
          // });

          userId = user.id;
          nextPage();

          try {
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.find<OtpReceiveController>().startOtpTimer();
            });
          } catch (e) {
            LogUtil.e(e);
          }
        },
        onError: (exception) {
          if (exception is AuthException) {
            if (exception.kind == AuthExceptionKind.phoneAlreadyInUse) {
              ViewUtil.showToast(
                title: l10n.register__title,
                message: l10n.error__phone_already_in_use,
              );
            } else if (exception.kind == AuthExceptionKind.custom) {
              final ServerError errors = exception.exception as ServerError;
              if (errors.fieldErrors.isNotEmpty) {
                for (var error in errors.fieldErrors) {
                  if (error.field == 'phone') {
                    ViewUtil.showToast(
                      title: l10n.register__title,
                      message: error.messages.first,
                    );
                  }
                }
              }
            }
          } else {
            ViewUtil.showToast(
              title: l10n.register__title,
              message: l10n.error__unknown,
            );
          }
        },
      );
    }
  }
}
