import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../../repositories/all.dart';
import '../../../../../services/all.dart';
import '../../../../base/all.dart';
import '../../../../common_controller.dart/all.dart';
import '../../../../routing/routing.dart';

class ReferralIdController extends BaseController {
  final _userRepo = Get.find<UserRepository>();
  final _authRepository = Get.find<AuthRepository>();

  final referralIdController = TextEditingController();

  final String? idToken = Get.arguments['id_token'] as String?;
  final String? accessToken = Get.arguments['access_token'] as String?;
  final String? platform = Get.arguments['platform'] as String?;

  Future<void> signInWithSignInThirdParty() async {
    await runAction(
      action: () async {
        final userId = await _authRepository.signInWithSignInThirdParty(
          idToken: idToken,
          accessToken: accessToken,
          platform: platform,
          refId: referralIdController.text,
        );

        await _onLoginSuccess(userId);
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
          } else if (e.kind == AuthExceptionKind.custom) {
            final ServerError errors = e.exception as ServerError;
            if (errors.fieldErrors.isNotEmpty) {
              for (var error in errors.fieldErrors) {
                if (error.field == 'ref_id') {
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
            title: l10n.global__error_title,
            message: l10n.global__error_has_occurred,
          );
        }
      },
    );
  }

  Future<void> _onLoginSuccess(int userId) async {
    await Future.delayed(const Duration(seconds: 1));

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
