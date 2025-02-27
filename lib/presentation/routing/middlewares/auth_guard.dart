import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common_controller.dart/app_controller.dart';
import '../routers/app_pages.dart';

class AuthGuard extends GetMiddleware {
  final AppController _appController = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    if (_appController.isLogged) {
      // if (!_appController.isSeenIntro) {
      //   return const RouteSettings(name: Routes.intro);
      // }

      return null;
    }

    return const RouteSettings(name: Routes.authOption);
  }
}
