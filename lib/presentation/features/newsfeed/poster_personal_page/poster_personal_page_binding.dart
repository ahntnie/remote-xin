import 'package:get/get.dart';

import 'all.dart';

class PosterPersonalPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosterPersonalPageController>(
      () => PosterPersonalPageController(),
      fenix: true,
    );
  }
}
