import 'package:get/get.dart';

import 'all.dart';

class CreateStoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateStoryController>(() => CreateStoryController());
  }
}
