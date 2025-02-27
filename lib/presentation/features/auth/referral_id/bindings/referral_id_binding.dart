import 'package:get/get.dart';

import '../controllers/referral_id_controller.dart';

class ReferralIdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferralIdController>(() => ReferralIdController());
  }
}
