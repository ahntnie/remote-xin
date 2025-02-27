import 'package:get/get.dart';

import '../../all.dart';
import '../../call_gateway/contact/all.dart';
import '../../chat/chat_hub/controllers/record_controller.dart';
import '../../chat/chat_hub/views/widgets/text_message_widget.dart';
import '../../zoom/zoom_home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.lazyPut(() => ChatDashboardController());

    Get.put<PersonalPageController>(PersonalPageController());
    Get.put<TextMessageController>(TextMessageController(), permanent: true);
    Get.put<RecordController>(
      RecordController(),
    );
    // chat
    // Get.put<CallGatewayController>(CallGatewayController());

    Get.lazyPut<ChatDashboardController>(() => ChatDashboardController());
    // Get.put<NumpadController>(NumpadController());

    // Get.lazyPut<SearchContactController>(() => SearchContactController());
    Get.lazyPut<ContactController>(() => ContactController());

    Get.put<ZoomHomeController>(ZoomHomeController());

    // travel
    // Get.put<TravelController>(TravelController());
    // Get.put<TravelPlaceController>(TravelPlaceController());

    Get.lazyPut<SettingController>(() => SettingController());

    //newfeed
    //  Get.lazyPut<CommentsController>(() => CommentsController());
    Get.lazyPut<SharePostController>(() => SharePostController());
    Get.put<PostsController>(PostsController());
  }
}
