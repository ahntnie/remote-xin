// ignore_for_file: unused_element

import '../../../../core/constants/storage_constants.dart';
import 'base_storage.dart';

class AppPreferences extends BaseStorage {
  @override
  String get boxName => StorageConstants.appPreferencesBox;

  Future<void> saveAccessToken(String value) async {
    return write(StorageConstants.accessTokenKey, value);
  }

  Future<String?> getAccessToken() async {
    return read(StorageConstants.accessTokenKey);
  }

  Future<void> saveRefreshToken(String value) async {
    return write(StorageConstants.refreshTokenKey, value);
  }

  Future<String?> getRefreshToken() async {
    return read(StorageConstants.refreshTokenKey);
  }

  Future<void> deleteAllTokens() async {
    await delete(StorageConstants.accessTokenKey);
    await delete(StorageConstants.refreshTokenKey);
  }
}
