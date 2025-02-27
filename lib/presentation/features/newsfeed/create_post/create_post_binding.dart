import 'package:get/get.dart';

import '../all.dart';

class CreatePostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatePostController>(() => CreatePostController());
    Get.lazyPut<PostInputResourceController>(
      () => PostInputResourceController(),
    );
  }
}
