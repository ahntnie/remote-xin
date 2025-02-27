import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../core/all.dart';

class ConnectivityService extends GetxService {
  bool isShowingDialog = false;

  @override
  Future<void> onInit() async {
    super.onInit();

    await Future.delayed(const Duration(seconds: 1));

    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      showNoConnectionDialog();
      isShowingDialog = true;
    }

    Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        showNoConnectionDialog();
        isShowingDialog = true;
      } else {
        if (isShowingDialog) {
          Get.back();
          isShowingDialog = false;
        }
      }
    });
  }

  void showNoConnectionDialog() {
    if (isShowingDialog) {
      return;
    }

    ViewUtil.showAppDialog(
      barrierDismissible: false,
      title: Get.context!.l10n.connectivity__no_internet_title,
      message: Get.context!.l10n.connectivity__no_internet_message,
    );
  }
}
