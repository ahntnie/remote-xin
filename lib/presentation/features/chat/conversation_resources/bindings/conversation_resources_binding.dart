import 'package:get/get.dart';

import '../controllers/conversation_resources_controller.dart';

class ConversationResourcesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationResourcesController>(
      () => ConversationResourcesController(),
    );
  }
}
