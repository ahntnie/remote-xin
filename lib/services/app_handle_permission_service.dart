import 'dart:io';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class AppHandlePermissionService {
  static const PERMISSION_CAMERA = Permission.camera;
  static const PERMISSION_MICROPHONE = Permission.microphone;
  static const PERMISSION_LOCATION = Permission.location;
  static const PERMISSION_CONTACTS = Permission.contacts;
  static const PERMISSION_CALENDAR = Permission.calendarFullAccess;
  static const PERMISSION_FILE_FOR_ABOVE_ANDROID_13 =
      Permission.manageExternalStorage; //ABOVE ANDROID 13
  static const PERMISSION_FILE_FOR_BELOW_ANDROID_12 =
      Permission.storage; //BELOW ANDROID 12

  ///SEND PERMISSION REQUEST BASE ON PERMISSION PARAM
  Future<void> sendPermissionRequest({required Permission permission}) async {
    if (await permission.status.isDenied) {
      await permission.request();
    }

    if (await permission.status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  ///SEND STORAGE PERMISSION REQUEST DEFINE FOR BOTH ANDROID & IOS
  Future<void> sendStoragePermissionRequest() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    if (Platform.isAndroid) {
      //Check Android Version
      if (androidInfo.version.sdkInt >= 33) {
        await _sendExternalStoragePermission();
      } else {
        await _sendStoragePermission();
      }
    }

    if (Platform.isIOS) {
      await _sendStoragePermission();
    }
  }

  ///SEND STORAGE PERMISSION REQUEST FOR ANDROID 13+
  Future<void> _sendExternalStoragePermission() async {
    if (await PERMISSION_FILE_FOR_ABOVE_ANDROID_13.status.isDenied) {
      await PERMISSION_FILE_FOR_ABOVE_ANDROID_13.request();
    }

    if (await PERMISSION_FILE_FOR_ABOVE_ANDROID_13.status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  ///SEND STORAGE PERMISSION REQUEST FOR ANDROID 12-
  Future<void> _sendStoragePermission() async {
    if (await PERMISSION_FILE_FOR_BELOW_ANDROID_12.status.isDenied) {
      await PERMISSION_FILE_FOR_BELOW_ANDROID_12.request();
    }

    if (await PERMISSION_FILE_FOR_BELOW_ANDROID_12.status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  ///CHECK APP PERMISSION GRANTED. IF ALL IS GRANTED RETURN TRUE
  Future<bool> checkAllPermissionGranted() async {
    if (!await PERMISSION_CAMERA.status.isGranted) {
      return false;
    }

    if (!await PERMISSION_MICROPHONE.status.isGranted) {
      return false;
    }

    if (!await _checkStoragePermissionGranted()) {
      return false;
    }

    return true;
  }

  ///CHECK STORAGE PERMISSION GRANTED. IF ALL IS GRANTED RETURN TRUE
  Future<bool> _checkStoragePermissionGranted() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    ///Platform is Android
    if (Platform.isAndroid) {
      ///ANDROID 13+
      if (androidInfo.version.sdkInt >= 33) {
        if (!await PERMISSION_FILE_FOR_ABOVE_ANDROID_13.status.isGranted) {
          return false;
        }
      }

      ///ANDROID 12-
      else {
        if (!await PERMISSION_FILE_FOR_BELOW_ANDROID_12.status.isGranted) {
          return false;
        }
      }
    }

    ///Platform if IOS
    if (Platform.isIOS) {
      if (!await PERMISSION_FILE_FOR_BELOW_ANDROID_12.status.isDenied) {
        return false;
      }
    }

    return true;
  }
}
