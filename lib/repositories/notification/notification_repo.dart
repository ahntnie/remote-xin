import 'package:get/get.dart';

import '../../data/api/clients/all.dart';
import '../../models/all.dart';
import '../base/base_repo.dart';
import 'documents/all.dart';

class NotificationRepository extends BaseRepository {
  final _graphQLApiClient = Get.find<AuthenticatedGraphQLApiClient>();
  final _authenticatedRestApiClient = Get.find<AuthenticatedRestApiClient>();

  Future<List<NotificationModel>> getNotifications({
    required int userId,
    required int pageSize,
    required int offset,
    SortOrderEnum sortOrder = SortOrderEnum.desc,
  }) async {
    // return executeApiRequest(
    //   () => _graphQLApiClient.query(
    //     document: getNotificationsDocument(
    //       userId: userId,
    //       pageSize: pageSize,
    //       offset: offset,
    //       sortOrder: sortOrder.name,
    //     ),
    //     decoder: (data) => NotificationModel.fromJsonList(
    //       (data as Map<String, dynamic>)['pi_xfactor_notifications']
    //           as List<dynamic>,
    //     ),
    //   ),
    // );
    return await executeApiRequest(
      () async {
        return _authenticatedRestApiClient.get(
          '/noti/get-list?page=$pageSize&per_page=10',
          decoder: (data) => NotificationModel.fromJsonList(
            (data as Map<String, dynamic>)['data'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<void> readNotification({required int notificationId}) async {
    await executeApiRequest(
      () => _graphQLApiClient.mutate(
        document: readNotificationDocument(),
        variables: {
          'notificationId': notificationId,
        },
        decoder: (_) => null,
      ),
    );
  }

  Future<int> getUnreadNotificationsCount({required int userId}) async {
    return executeApiRequest(
      () => _graphQLApiClient.query(
        document: getUnreadNotificationsCountDocument(
          userId: userId,
        ),
        decoder: (data) =>
            (data as Map<String, dynamic>)['pi_xfactor_notifications_aggregate']
                ['aggregate']['count'] as int,
      ),
    );
  }
}
