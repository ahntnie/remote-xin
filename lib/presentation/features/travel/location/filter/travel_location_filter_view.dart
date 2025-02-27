import 'package:flutter/material.dart';

import '../../../../base/base_view.dart';
import 'travel_location_filter_controller.dart';

class TravelLocationFilterView
    extends BaseView<TravelLocationFilterController> {
  const TravelLocationFilterView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [Text('TravelLocationView')],
      ),
    );
  }
}
