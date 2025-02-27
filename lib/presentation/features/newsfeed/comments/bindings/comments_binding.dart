import 'package:get/get.dart';

import '../controllers/root_comment_controller.dart';

class CommentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.create(() => RootCommentController());
  }
}
