import 'package:get/get.dart';

import '../all.dart';

class PostsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostsController>(() => PostsController());
    // Get.lazyPut<CommentsController>(() => CommentsController());
    Get.lazyPut<SharePostController>(() => SharePostController());
  }
}
