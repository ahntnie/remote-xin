import 'package:get/get.dart';

import '../../../core/configs/env_config.dart';
import '../interceptors/access_token_interceptor.dart';
import 'base/rest_api_client.dart';

class ChatApiClient extends RestApiClient {
  ChatApiClient()
      : super(
          baseUrl: Get.find<EnvConfig>().chatApiUrl,
          interceptors: [AccessTokenInterceptor()],
        );
}
