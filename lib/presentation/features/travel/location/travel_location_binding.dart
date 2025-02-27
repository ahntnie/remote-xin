import 'package:get/get.dart';

import 'travel_location_controller.dart';

class TravelLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TravelLocationController>(() => TravelLocationController());
  }
}
