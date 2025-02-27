import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_ticket_provider_mixin.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../base/base_controller.dart';

class TravelController extends BaseController with GetTickerProviderStateMixin {
  late WebViewController travelWebViewController;

  @override
  void onInit() {
    // travelWebViewController = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..loadRequest(Uri.parse("https://example.com"));
    super.onInit();
  }
}
