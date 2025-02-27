import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../../repositories/all.dart';
import '../../../../../services/all.dart';
import '../../../../base/all.dart';
import '../../../../common_controller.dart/app_controller.dart';
import '../../../../routing/routing.dart';
import '../../otp_receive/controllers/otp_receive_controller.dart';

enum LoginKind {
  email,
  phone,
}

class LoginController extends BaseController {
  final AuthRepository _authService = Get.find();
  final UserRepository _userRepo = Get.find();
  final appController = Get.find<AppController>();

  var isHidePassword = true.obs;
  var isDisableLoginBtn = true.obs;
  var loginKind = LoginKind.email.obs;

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  FocusNode phoneFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  RxString phoneLogin = ''.obs;
  RxString initIsoCode = 'VN'.obs;

  final PageController pageControllerLogin = PageController();
  RxInt currentPage = 0.obs;
  RxBool isRegister = false.obs;
  RxBool isPhone = false.obs;

  final phonePattern = r'^[0-9]+$';
  final emailPattern = r'^.+@gmail\.com$';

  void reset() {
    isHidePassword.value = true;
    isDisableLoginBtn.value = true;
    loginKind.value = LoginKind.email;
    emailController.text = '';
    phoneController.text = '';
    passwordController.text = '';
    phoneLogin.value = '';
    currentPage.value = 0;
    isRegister.value = false;
    isPhone.value = false;
    update();
  }

  void nextPage() {
    pageControllerLogin.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    currentPage++;
  }

  void previousPage() {
    pageControllerLogin.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    currentPage--;
  }

  set setHidePassword(bool value) {
    isHidePassword.value = value;
    update();
  }

  set setDisableLoginBtn(bool value) {
    isDisableLoginBtn.value = value;
    update();
  }

  set setLoginKind(LoginKind kind) {
    loginKind.value = kind;
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

    update();
  }

  String validateEmail(String email) {
    if (!ValidationUtil.isEmptyEmail(email)) {
      return l10n.field__email_error_empty;
    }

    if (!ValidationUtil.isValidEmail(email)) {
      return l10n.field__email_error_invalid;
    }

    return '';
  }

  String validatePassword(String password) {
    if (password.isEmpty) {
      return l10n.field__password_error_empty;
    }

    if (!ValidationUtil.isValidPassword(password)) {
      return l10n.field__password_error_invalid;
    }

    return '';
  }

  Future<void> login() async {
    if (isLoading) {
      return;
    }

    await runAction(
      action: () async {
        // if (loginKind.value == LoginKind.email) {
        //   final userId = await _authService.login(
        //     email: emailController.text,
        //     password: passwordController.text,
        //   );

        //   await _onLoginSuccess(userId);
        // } else if (loginKind.value == LoginKind.phone) {
        //   final userId = await _authService.login(
        //     phone: phoneLogin.value.removeAllWhitespace,
        //     password: passwordController.text,
        //   );

        //   await _onLoginSuccess(userId);
        // }
        if (RegExp(emailPattern).hasMatch(emailController.text)) {
          final userId = await _authService.login(
            email: emailController.text,
            password: passwordController.text,
          );
          await _onLoginSuccess(userId);
        } else {
          final userId = await _authService.login(
            phone: emailController.text,
            password: passwordController.text,
          );
          await _onLoginSuccess(userId);
        }
      },
      onError: (e) {
        final title = l10n.login__error_title;
        late String message;

        // ignore: prefer-conditional-expressions
        if (e is AuthException && e.kind == AuthExceptionKind.userIsLocked) {
          message = l10n.login__error_user_is_locked;
        } else {
          message = l10n.login__error_invalid_credential;
        }

        ViewUtil.showToast(
          title: title,
          message: message,
        );
      },
    );
  }

  Future<void> _onLoginSuccess(int userId) async {
    await Future.delayed(const Duration(seconds: 1));

    Get.find<NotificationBadgeCountService>();
    unawaited(Get.find<PushNotificationService>().initFirebaseMessaging());
    User currentUser = await _userRepo.getUserById(userId);

    if (loginKind.value == LoginKind.email) {
      currentUser = currentUser.copyWith(
        loginLocal: emailController.text,
      );
    } else if (loginKind.value == LoginKind.phone) {
      currentUser = currentUser.copyWith(
        loginLocal: phoneLogin.value,
      );
    }

    Get.find<AppController>().setLoggedUser(currentUser);
    Get.find<AppController>().setLogged(true);

    await Get.find<ChatSocketService>().onInit();
    await Get.find<ChatSocketService>().connectSocket();

    if (currentUser.nickname != null && currentUser.nickname!.isNotEmpty) {
      // if (currentUser.nftNumber == null || currentUser.nftNumber!.isEmpty) {
      //   await showModalBottomSheet(
      //     context: Get.context!,
      //     isScrollControlled: true,
      //     builder: (context) => BottomSheetChooseNumber(
      //       currentUser: currentUser,
      //       type: 'login',
      //     ),
      //     useSafeArea: true,
      //   );
      // } else {
      unawaited(Get.offNamed(AppPages.afterAuthRoute));
      // }
    } else {
      unawaited(
        Get.offNamed(
          Routes.profile,
          arguments: {'isUpdateProfileFirstLogin': true},
        ),
      );
    }
  }

  void goToForgotPassword() {
    Get.toNamed(Routes.forgotPassword);
  }

  final _authRepository = Get.find<AuthRepository>();

  RxString localeDefault = 'EN'.obs;
  RxBool isAppleSignInAvailable = false.obs;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: const <String>['email'],
  );

  @override
  void onInit() {
    getAppleSignInAvailable();
    super.onInit();
  }

  void getAppleSignInAvailable() {
    SignInWithApple.isAvailable().then((value) {
      isAppleSignInAvailable.value = value;
    });
  }

  void signInWithGoogle() {
    runAction(
      action: () async {
        await googleSignIn.signOut();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser != null) {
          final googleAuth = await googleUser.authentication;

          final CheckAccountExist checkAccountExist =
              await _authRepository.checkAccountExistWithSignInThirdParty(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
            platform: PlatFormLoginEnum.google.name,
          );

          if (checkAccountExist.accountExist) {
            final userId = await _authRepository.signInWithSignInThirdParty(
              idToken: googleAuth.idToken,
              accessToken: googleAuth.accessToken,
              platform: PlatFormLoginEnum.google.name,
            );

            await _onLoginSuccess(userId);
          } else {
            unawaited(Get.toNamed(Routes.referralId, arguments: {
              'id_token': googleAuth.idToken,
              'access_token': googleAuth.accessToken,
              'platform': PlatFormLoginEnum.google.name,
            }));
          }
        }
      },
      onError: (e) {
        if (e is AuthException) {
          if (e.kind == AuthExceptionKind.userIsAdmin) {
            ViewUtil.showToast(
              title: l10n.register__title,
              message: l10n.error__user_is_admin,
            );
          } else if (e.kind == AuthExceptionKind.userIsLocked) {
            ViewUtil.showToast(
              title: l10n.register__title,
              message: l10n.login__error_user_is_locked,
            );
          }
        } else {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.global__error_has_occurred,
          );
        }
      },
    );
  }

  void signInWithApple() {
    runAction(
      action: () async {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        // Use the credential to sign in with your backend server
        final CheckAccountExist checkAccountExist =
            await _authRepository.checkAccountExistWithSignInThirdParty(
          idToken: credential.identityToken,
          platform: PlatFormLoginEnum.apple.name,
        );

        if (checkAccountExist.accountExist) {
          final userId = await _authRepository.signInWithSignInThirdParty(
            idToken: credential.identityToken,
            platform: PlatFormLoginEnum.apple.name,
          );

          await _onLoginSuccess(userId);
        } else {
          unawaited(Get.toNamed(Routes.referralId, arguments: {
            'id_token': credential.identityToken,
            'platform': PlatFormLoginEnum.apple.name,
          }));
        }
      },
      onError: (e) {
        if (e is AuthException) {
          if (e.kind == AuthExceptionKind.userIsAdmin) {
            ViewUtil.showToast(
              title: l10n.register__title,
              message: l10n.error__user_is_admin,
            );
          } else if (e.kind == AuthExceptionKind.userIsLocked) {
            ViewUtil.showToast(
              title: l10n.register__title,
              message: l10n.login__error_user_is_locked,
            );
          }
        } else {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.global__error_has_occurred,
          );
        }
      },
    );
  }

  Future<void> resendOtpForgotPassword() async {
    await runAction(
      action: () async {
        if (RegExp(emailPattern).hasMatch(emailController.text)) {
          final String? code = await _authService.requestResendOTP(
            email: emailController.text,
            type: 'reset-password',
          );

          if (code != null) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.otp__resend_success,
            );
          }
        } else {
          final String? code = await _authService.requestResendOTP(
            phone: phoneLogin.value,
            type: 'reset-password',
          );

          if (code != null) {
            ViewUtil.showToast(
              title: l10n.otp__title,
              message: l10n.otp__resend_success,
            );

            try {
              Future.delayed(const Duration(milliseconds: 500), () {
                Get.find<OtpReceiveController>().startOtpTimer();
              });
            } catch (e) {
              LogUtil.e(e);
            }
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
}
