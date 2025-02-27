import 'package:get/get.dart';

import 'all.dart';

class PostDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostDetailController>(
      () => PostDetailController(),
      fenix: true,
    );
  }
}
