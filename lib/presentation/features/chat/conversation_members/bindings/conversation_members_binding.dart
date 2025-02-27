import 'package:get/get.dart';

import '../controllers/conversation_members_controller.dart';

class ConversationMembersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationMembersController>(
      () => ConversationMembersController(),
    );
  }
}
