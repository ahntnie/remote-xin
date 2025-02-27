import 'package:get/get.dart';

import '../all.dart';
import '../zoom/zoom_home_controller.dart';
import 'call_gateway_controller.dart';
import 'call_history/call_history_controller.dart';
import 'contact/all.dart';
import 'numpad/numpad_controller.dart';
import 'numpad/search_contact/search_contact_controller.dart';

class CallGatewayBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CallGatewayController>(CallGatewayController());
    Get.put<CallHistoryController>(CallHistoryController());
    Get.put<ZoomHomeController>(ZoomHomeController());

    Get.lazyPut<ChatDashboardController>(() => ChatDashboardController());
    Get.put<NumpadController>(NumpadController());

    Get.lazyPut<SearchContactController>(() => SearchContactController());
    Get.lazyPut<ContactController>(() => ContactController());

    // Get.lazyPut<PersonalPageHiddenNewfeedController>(
    //   () => PersonalPageHiddenNewfeedController(),
    // );
    Get.put<HomeController>(HomeController());
  }
}
