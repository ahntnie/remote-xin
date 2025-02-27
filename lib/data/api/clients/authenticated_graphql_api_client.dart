import 'package:get/get.dart';

import '../../../../../core/configs/all.dart';
import '../interceptors/access_token_interceptor.dart';
import 'base/graphql_api_client.dart';

class AuthenticatedGraphQLApiClient extends GraphQLApiClient {
  AuthenticatedGraphQLApiClient()
      : super(
          baseUrl: Get.find<EnvConfig>().hasuraUrl,
          interceptors: [AccessTokenInterceptor()],
        );
}
