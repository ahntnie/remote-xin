import 'package:get/get.dart';

import '../../../core/configs/env_config.dart';
import 'base/rest_api_client.dart';

class ManaMissionApiClient extends RestApiClient {
  ManaMissionApiClient()
      : super(
          baseUrl: Get.find<EnvConfig>().missionUrl,
        );
}
