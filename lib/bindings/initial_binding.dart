import 'package:event_bus/event_bus.dart';
import 'package:get/get.dart';

import '../data/api/clients/all.dart';
import '../data/api/clients/mana_mission_api_client.dart';
import '../data/preferences/app_preferences.dart';
import '../presentation/common_controller.dart/user_pool.dart';
import '../presentation/features/all.dart';
import '../repositories/all.dart';
import '../repositories/map_linking_repo.dart';
import '../repositories/missions/mana_mission_repo.dart';
import '../repositories/missions/translate_repo.dart';
import '../repositories/short-video/short_video_repo.dart';
import '../services/all.dart';
import '../services/newsfeed_interact_service.dart';
import '../services/receive_sharing_intent_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    _bindDatasource();
    _bindRepository();
    _initServices();
  }

  void _bindDatasource() {
    Get.put<AppPreferences>(AppPreferences(), permanent: true);
    Get.put<EventBus>(EventBus(), permanent: true);
    Get.put<UnAuthenticatedRestApiClient>(UnAuthenticatedRestApiClient());
    Get.put<AuthenticatedRestApiClient>(AuthenticatedRestApiClient());
    Get.put<AuthenticatedGraphQLApiClient>(
      AuthenticatedGraphQLApiClient(),
    );
    Get.put<ChatApiClient>(ChatApiClient());

    Get.put<ManaMissionApiClient>(ManaMissionApiClient());
  }

  void _bindRepository() {
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    Get.lazyPut<ChatRepository>(() => ChatRepository(), fenix: true);
    Get.lazyPut<CallRepository>(() => CallRepository(), fenix: true);
    Get.lazyPut<StorageRepository>(() => StorageRepository(), fenix: true);
    Get.lazyPut<ContactRepository>(() => ContactRepository(), fenix: true);
    Get.lazyPut<AppConfigRepository>(() => AppConfigRepository(), fenix: true);
    Get.lazyPut<NewsfeedRepository>(() => NewsfeedRepository(), fenix: true);
    Get.lazyPut<MapLinkingRepository>(() => MapLinkingRepository(),
        fenix: true);
    Get.lazyPut<ManaMissionRepository>(
      () => ManaMissionRepository(),
      fenix: true,
    );
    Get.lazyPut<SharedLinkRepository>(
      () => SharedLinkRepository(),
      fenix: true,
    );
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(),
      fenix: true,
    );
    Get.lazyPut<ShortVideoRepository>(() => ShortVideoRepository(),
        fenix: true);
    Get.lazyPut<TranslateRepository>(() => TranslateRepository(), fenix: true);
  }

  void _initServices() {
    Get.put<UserPool>(UserPool(), permanent: true);
    Get.put<PushNotificationService>(
      PushNotificationService(),
      permanent: true,
    );
    Get.put<ChatSocketService>(ChatSocketService(), permanent: true);
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<SoundService>(SoundService(), permanent: true);
    Get.put<AppConfigService>(AppConfigService(), permanent: true);
    Get.put<DeepLinkService>(DeepLinkService(), permanent: true);
    Get.put<NewsfeedInteractService>(
      NewsfeedInteractService(),
      permanent: true,
    );

    Get.lazyPut<ChatDashboardController>(
      () => ChatDashboardController(),
      fenix: true,
    );
    Get.lazyPut<NotificationBadgeCountService>(
      () => NotificationBadgeCountService(),
      fenix: true,
    );

    Get.put<ReceiveSharingIntentService>(ReceiveSharingIntentService(),
        permanent: true);
  }
}
