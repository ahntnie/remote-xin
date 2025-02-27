import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/preferences/app_preferences.dart';
import '../../../../models/user.dart';
import '../../../../repositories/all.dart';
import '../../../../services/all.dart';
import '../../../base/all.dart';
import '../../../common_controller.dart/all.dart';
import '../../../routing/routers/app_pages.dart';

class SplashController extends BaseController {
  final _appPreferences = Get.find<AppPreferences>();
  final _chatSocketService = Get.find<ChatSocketService>();
  final _userRepo = Get.find<UserRepository>();

  final int gifDuration = 6000;

  @override
  Future<void> onReady() async {
    final appController = Get.find<AppController>();

    await appController.restoreStateCompleter.future;

    final token = await _appPreferences.getAccessToken();
    if (appController.lastLoggedUser != null &&
        token != null &&
        token.isNotEmpty &&
        currentUser.nftNumber != null &&
        currentUser.nftNumber!.isNotEmpty &&
        currentUser.nftNumber! != 'null') {
      await _chatSocketService.connectSocket();

      // unawaited(Get.offNamed(Routes.callGateway));

      await _getCurrentUser();

      if (currentUser.nickname != null && currentUser.nickname!.isNotEmpty) {
        // await Future.delayed(Duration(milliseconds: gifDuration), () {
        //   unawaited(Get.offNamed(AppPages.afterAuthRoute));
        //   Get.find<NotificationBadgeCountService>();
        // });
        unawaited(Get.offNamed(AppPages.afterAuthRoute));
        Get.find<NotificationBadgeCountService>();
      } else if (currentUser.isDeactivated()) {
        await logout();
      } else {
        unawaited(
          Get.offNamed(
            Routes.profile,
            arguments: {'isUpdateProfileFirstLogin': true},
          ),
        );
      }
    } else {
      // await Future.delayed(Duration(milliseconds: gifDuration), () {
      //   Get.offNamed(Routes.authOption);

      // });
      Get.offNamed(Routes.authOption);
    }

    super.onReady();
  }

  Future<void> _getCurrentUser() async {
    await runAction(
      handleLoading: false,
      action: () async {
        final AppController appController = Get.find();

        final User user = await _userRepo.getUserById(currentUser.id);

        appController.setLoggedUser(user);
      },
    );
  }
}
