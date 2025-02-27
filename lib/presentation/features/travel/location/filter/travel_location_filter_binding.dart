import 'package:get/get.dart';

import 'travel_location_filter_controller.dart';

class TravelLocationFilterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TravelLocationFilterController>(
        () => TravelLocationFilterController());
  }
}
