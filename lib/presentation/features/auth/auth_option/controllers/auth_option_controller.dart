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
import '../../../../common_controller.dart/all.dart';
import '../../../../routing/routing.dart';

class AuthOptionController extends BaseController {
  AuthOptionController() : super();
  final _authRepository = Get.find<AuthRepository>();
  final _userRepo = Get.find<UserRepository>();

  RxString localeDefault = 'EN'.obs;
  RxBool isAppleSignInAvailable = false.obs;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: const <String>['email'],
  );

  @override
  void onInit() {
    getLocaleDefault();
    getAppleSignInAvailable();
    super.onInit();
  }

  void getLocaleDefault() {
    localeDefault.value = LocaleConfig.defaultLocale.languageCode == 'en'
        ? l10n.locale_en
        : l10n.locale_vi;
  }

  void updateLocaleDefault(String locale) {
    if (locale == l10n.locale_en) {
      Get.updateLocale(const Locale('en'));
      localeDefault.value = l10n.locale_en;
    } else {
      Get.updateLocale(const Locale('vi'));
      localeDefault.value = l10n.locale_vi;
    }
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

  void getAppleSignInAvailable() {
    SignInWithApple.isAvailable().then((value) {
      isAppleSignInAvailable.value = value;
    });
  }

  Future<void> _onLoginSuccess(int userId) async {
    await Future.delayed(const Duration(seconds: 1));

    Get.find<NotificationBadgeCountService>();
    unawaited(Get.find<PushNotificationService>().initFirebaseMessaging());
    User currentUser = await _userRepo.getUserById(userId);

    currentUser = currentUser.copyWith(
      loginLocal: currentUser.email,
    );

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
