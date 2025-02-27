import 'package:get/get.dart';

import 'map_linking_controller.dart';

class MapLinkingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapLinkingController>(() => MapLinkingController());
  }
}
