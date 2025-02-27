import 'package:get/get.dart';

import '../../core/configs/env_config.dart';
import '../../data/api/clients/base/rest_api_client.dart';
import 'base/base_repo.dart';

class TranslateRepository extends BaseRepository {
  final _client =
      RestApiClient(baseUrl: Get.find<EnvConfig>().translateServiceUrl);

  Future<String> translate({
    required String text,
    required String to,
  }) async {
    final headers = {
      'lang': 'vn',
      'gmt': '1',
      'os-name': '.',
      'os-version': '.',
      'app-version': '.',
      'Content-Type': 'application/json',
      'uuid': '.',
    };

    final res = await _client.post(
      '/translate-audio/translate-list',
      headers: headers,
      body: {
        'to-lang': to,
        'messages': {
          '1': text,
        },
      },
      decoder: (data) => data,
    );

    return (res['data'] as Map<String, dynamic>).values.first.toString();
  }
}
