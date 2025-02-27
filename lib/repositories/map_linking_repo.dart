import 'package:get/get.dart';

import '../core/all.dart';
import '../data/api/clients/base/rest_api_client.dart';
import '../models/map_linking/category_map.dart';
import '../models/map_linking/position_map.dart';
import 'base/base_repo.dart';

class MapLinkingRepository extends BaseRepository {
  final _client = RestApiClient(baseUrl: Get.find<EnvConfig>().mapUrl);

  Future<List<CategoryMap>> getCategoryMap() async {
    return executeApiRequest(
      () async {
        return _client.get(
          '/map-address/map-address-category',
          decoder: (data) => CategoryMap.fromJsonList((data
              as Map<String, dynamic>)['data']['results'] as List<dynamic>),
        );
      },
    );
  }

  Future<List<PositionMap>> getPositionMap(String id) async {
    return executeApiRequest(
      () async {
        return _client.get(
          '/map-address/map-address?category_id=$id&limit=10&page=1',
          decoder: (data) => PositionMap.fromJsonList((data
              as Map<String, dynamic>)['data']['results'] as List<dynamic>),
        );
      },
    );
  }
}
