import 'package:get/get.dart';

import '../../../all.dart';
import '../../otp_receive/controllers/otp_receive_controller.dart';
import '../../reset_password/controllers/reset_password_controller.dart';

class AuthOptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthOptionController>(() => AuthOptionController());
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<RegisterController>(() => RegisterController());

    Get.lazyPut<OtpReceiveController>(() => OtpReceiveController());
    Get.lazyPut<ResetPasswordController>(() => ResetPasswordController());
  }
}
