import 'package:get/get.dart';

import '../../../base/all.dart';
import '../../../common_controller.dart/app_controller.dart';
import '../../../routing/routers/app_pages.dart';

class IntroController extends BaseController {
  var currentIndex = 0.obs;

  set changeTab(int index) {
    currentIndex.value = index;
    update();
  }

  void nextStep() {
    if (currentIndex.value < 2) {
      currentIndex.value++;
      update();
    } else {
      skip();
    }
  }

  String textButton() {
    if (currentIndex.value < 2) {
      return 'Tiếp tục';
    }

    return 'Bắt đầu';
  }

  String textTitle() {
    if (currentIndex.value == 0) {
      return l10n.intro__title;
    } else if (currentIndex.value == 1) {
      return l10n.intro__title;
    }

    return l10n.intro__title;
  }

  String subTitle() {
    if (currentIndex.value == 0) {
      return l10n.intro__sub_title_step_1;
    } else if (currentIndex.value == 1) {
      return l10n.intro__sub_title_step_1;
    }

    return l10n.intro__sub_title_step_1;
  }

  void skip() {
    Get.find<AppController>().setSeenIntro(true);
    Get.offNamed(AppPages.afterAuthRoute);
  }
}
