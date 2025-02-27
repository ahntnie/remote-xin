import 'package:get/get.dart';

import '../controllers/in_coming_call_controller.dart';

class CallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InComingCallController>(
      () => InComingCallController(),
      fenix: true,
    );
  }
}
