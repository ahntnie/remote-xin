import 'package:package_info_plus/package_info_plus.dart';

import '../utils/log_util.dart';

class AppInfo {
  AppInfo._();

  static PackageInfo? _packageInfo;
  static late final AppFlavor appFlavor;

  static String get appName => _packageInfo?.appName ?? '';
  static String get applicationId => _packageInfo?.packageName ?? '';
  static String get versionName => _packageInfo?.version ?? '';
  static String get buildNumber => _packageInfo?.buildNumber ?? '';

  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    LogUtil.i(applicationId, name: 'APPLICATION_ID');
    LogUtil.i(appName, name: 'APP_NAME');
    LogUtil.i(versionName, name: 'VERSION_NAME');
    LogUtil.i(buildNumber, name: 'BUILD_NUMBER');
  }

  static bool get isDev => appFlavor == AppFlavor.dev;
  static bool get isProd => appFlavor == AppFlavor.prod;
}

enum AppFlavor { dev, prod }
