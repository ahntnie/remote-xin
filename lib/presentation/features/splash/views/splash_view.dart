import 'package:flutter/material.dart';

import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../controllers/splash_controller.dart';

class SplashView extends BaseView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      isShowLinearBackground: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Assets.images.splashImage.image()],
      ),
    );
  }
}
