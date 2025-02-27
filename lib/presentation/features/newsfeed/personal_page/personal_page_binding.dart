import 'package:get/get.dart';

import '../../all.dart';

class PersonalPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersonalPageController>(
      () => PersonalPageController(),
      fenix: true,
    );
  }
}
