import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../preferences/app_preferences.dart';
import 'base_interceptor.dart';

class AccessTokenInterceptor extends BaseInterceptor {
  AccessTokenInterceptor();

  @override
  int get priority => BaseInterceptor.accessTokenPriority;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await Get.find<AppPreferences>().getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return super.onRequest(options, handler);
  }
}
