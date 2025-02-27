import 'package:get/get.dart';

import '../../data/api/clients/mana_mission_api_client.dart';
import '../../models/enums/mission_mana_type_enum.dart';
import '../../models/mana_mission/mana.dart';
import '../../models/mana_mission/mana_mission.dart';
import '../base/base_repo.dart';

class ManaMissionRepository extends BaseRepository {
  final _authenticatedRestApiClient = Get.find<ManaMissionApiClient>();

  Future<List<ManaMission>> getManaMissionsDay(
      String user, ManaMissionTypeEnum type) async {
    return executeApiRequest(() async {
      return _authenticatedRestApiClient.post(
        '/mission/mana-day',
        body: {
          'user': user,
          // 'type': type.name,
        },
        decoder: (data) => ManaMission.fromJsonList(
          (data as Map<String, dynamic>)['data'] as List<dynamic>,
        ),
      );
    });
  }

  Future<Mana> getMana(String user) {
    return executeApiRequest(() async {
      return _authenticatedRestApiClient.get(
        '/user/mana/$user',
        decoder: (data) =>
            Mana.fromJson((data as Map<String, dynamic>)['data']),
      );
    });
  }
}
