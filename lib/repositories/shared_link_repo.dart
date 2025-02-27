import 'package:get/get.dart';

import '../data/api/clients/authenticated_rest_api_client.dart';
import '../data/mappers/response_mapper/base/base_success_response_mapper.dart';
import 'base/base_repo.dart';

class SharedLinkRepository extends BaseRepository {
  final _client = Get.find<AuthenticatedRestApiClient>();

  Future<String> getSharedLink({
    required SharedLinkType type,
    required dynamic id,
  }) async {
    return executeApiRequest(
      () async {
        final res = await _client.post(
          '/sharelink',
          body: {'id': id, 'type': type.name},
          successResponseMapperType: SuccessResponseMapperType.plain,
        );

        return res['link'];
      },
    );
  }
}

enum SharedLinkType { post, conversation, user }
