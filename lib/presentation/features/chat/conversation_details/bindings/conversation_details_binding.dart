import 'package:get/get.dart';

import '../../../all.dart';

class ConversationDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationDetailsController>(
      () => ConversationDetailsController(),
    );
  }
}
