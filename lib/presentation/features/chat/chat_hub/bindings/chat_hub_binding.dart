import 'package:get/get.dart';

import '../controllers/chat_hub_controller.dart';
import '../controllers/chat_input_controller.dart';

class ChatHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatHubController>(ChatHubController());
    Get.lazyPut<ChatInputController>(
      () => ChatInputController(
        chatHubController: Get.find<ChatHubController>(),
      ),
    );
  }
}
