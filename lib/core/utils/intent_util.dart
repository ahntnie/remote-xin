import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/all.dart';

class IntentUtils {
  const IntentUtils._();

  static Future<bool> openBrowserURL({
    required String url,
    bool inApp = false,
  }) async {
    if (url.startsWith(kDeepLinkPrefix)) {
      final deepLinkService = Get.find<DeepLinkService>();

      return deepLinkService.handleDeepLink(url);
    }

    return launchUrl(Uri.parse(url));
  }
}
