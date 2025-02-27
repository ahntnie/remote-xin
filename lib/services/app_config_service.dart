import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/all.dart';
import '../repositories/app_config_repo.dart';

class AppConfigService extends GetxService
    with LogMixin, WidgetsBindingObserver {
  final _appConfigRepository = Get.find<AppConfigRepository>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    _getServerSettings();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> _goToStore() async {
    final url =
        Platform.isAndroid ? AppConstants.chPlayUrl : AppConstants.appStoreUrl;

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @mustCallSuper
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // _getServerSettings();
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
    }
  }

  Future<void> _getServerSettings() async {
    final serverSettings = await _appConfigRepository.getServerSettings();

    if (serverSettings.isMaintaining) {
      return _showMaintenanceDialog();
    }

    // if (serverSettings.isForceUpdate) {
    //   return _showForceUpdateDialog();
    // }
  }

  void _showMaintenanceDialog() {
    final l10n = Get.context!.l10n;

    ViewUtil.showAppDialog(
      barrierDismissible: false,
      title: l10n.app_config__maintenance_title,
      message: l10n.app_config__maintenance_message,
    );
  }

  void _showForceUpdateDialog() {
    final l10n = Get.context!.l10n;

    ViewUtil.showAppDialog(
      barrierDismissible: false,
      title: l10n.app_config__force_update_title,
      message: l10n.app_config__force_update_message,
      positiveText: l10n.app_config__force_update_button,
      onPositivePressed: _goToStore,
    );
  }
}
