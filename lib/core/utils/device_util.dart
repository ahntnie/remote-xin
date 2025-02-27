import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_udid/flutter_udid.dart';

class DeviceUtil {
  const DeviceUtil._();

  static Future<String?> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final String uuid = await FlutterUdid.udid;

      return uuid; // unique ID on iOS
    } else if (Platform.isAndroid) {
      final androidDeviceInfo = await deviceInfo.androidInfo;

      return androidDeviceInfo.id; // unique ID on Android
    } else if (kIsWeb) {
      // The web doesnt have a device UID, so use a combination fingerprint as an example
      final WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;

      return webInfo.vendor! +
          webInfo.userAgent! +
          webInfo.hardwareConcurrency.toString();
    } else if (Platform.isLinux) {
      final LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;

      return linuxInfo.machineId;
    } else if (Platform.isWindows) {
      final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;

      return windowsInfo.deviceId;
    }

    return null;
  }

  static Future<String?> getDeviceModelName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosDeviceInfo = await deviceInfo.iosInfo;

      return iosDeviceInfo.name;
    } else if (Platform.isAndroid) {
      final androidDeviceInfo = await deviceInfo.androidInfo;

      return androidDeviceInfo.model;
    } else if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;

      return webInfo.userAgent!;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;

      return linuxInfo.name;
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;

      return windowsInfo.computerName;
    }

    return null;
  }

  static String getDeviceOS() {
    if (Platform.isIOS) {
      return 'IOS';
    }
    if (Platform.isAndroid) {
      return 'Android';
    }
    if (kIsWeb) {
      return 'Web';
    }
    if (Platform.isLinux) {
      return 'Linux';
    }
    if (Platform.isWindows) {
      return 'Windows';
    }

    return '';
  }
}
