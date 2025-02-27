import 'package:get/get.dart';

import '../../../../../core/configs/all.dart';
import '../interceptors/access_token_interceptor.dart';
import 'base/rest_api_client.dart';

class AuthenticatedRestApiClient extends RestApiClient {
  AuthenticatedRestApiClient()
      : super(
          baseUrl: Get.find<EnvConfig>().apiUrl,
          interceptors: [AccessTokenInterceptor()],
        );
}
