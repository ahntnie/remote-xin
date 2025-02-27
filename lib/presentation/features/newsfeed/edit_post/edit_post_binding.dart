import 'package:get/get.dart';

import '../all.dart';

class EditPostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditPostController>(() => EditPostController());
    Get.lazyPut<PostInputResourceController>(
      () => PostInputResourceController(),
    );
  }
}
