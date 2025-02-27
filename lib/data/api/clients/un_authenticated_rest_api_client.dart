import 'package:get/get.dart';

import '../../../../../core/configs/all.dart';
import 'base/rest_api_client.dart';

class UnAuthenticatedRestApiClient extends RestApiClient {
  UnAuthenticatedRestApiClient() : super(baseUrl: Get.find<EnvConfig>().apiUrl);
}
