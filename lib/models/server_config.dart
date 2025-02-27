import 'dart:io';

import '../core/helpers/app_info.dart';

class ServerSettings {
  final int androidMinVersionCode;
  final int iosMinVersionCode;
  final bool isMaintaining;

  ServerSettings({
    required this.androidMinVersionCode,
    required this.iosMinVersionCode,
    required this.isMaintaining,
  });

  factory ServerSettings.fromJson(Map<String, dynamic> json) {
    return ServerSettings(
      androidMinVersionCode: json['android_min_version_code'] as int,
      iosMinVersionCode: json['ios_min_version_code'] as int,
      isMaintaining: json['is_maintaining'] as bool,
    );
  }

  bool get isForceUpdate {
    final appBuildNumber = AppInfo.buildNumber;

    return Platform.isAndroid
        ? int.parse(appBuildNumber) < androidMinVersionCode
        : int.parse(appBuildNumber) < iosMinVersionCode;
  }
}
