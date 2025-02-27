// export 'api/api.dart';
// export 'preference/base_preference.dart';

import 'package:get/get.dart';

import 'api/clients/all.dart';
import 'preferences/app_preferences.dart';

class ClientProvider {
  ClientProvider._internal();
  static final ClientProvider _instance = ClientProvider._internal();
  static ClientProvider get instance => _instance;

  AppPreferences get appPreferences => Get.find<AppPreferences>();

  AuthenticatedRestApiClient get authenticatedRestApiClient =>
      Get.find<AuthenticatedRestApiClient>();
  UnAuthenticatedRestApiClient get unAuthenticatedRestApiClient =>
      Get.find<UnAuthenticatedRestApiClient>();

  AuthenticatedGraphQLApiClient get authenticatedGraphQLApiClient =>
      Get.find<AuthenticatedGraphQLApiClient>();
  ChatApiClient get chatApiClient => Get.find<ChatApiClient>();
}
