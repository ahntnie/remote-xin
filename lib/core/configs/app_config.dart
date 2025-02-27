import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../presentation/common_controller.dart/all.dart';
import '../../presentation/common_controller.dart/language_controller.dart';
import '../../presentation/features/notification/notification_controller.dart';
import '../helpers/app_info.dart';
import 'env_config.dart';
import 'firebase/firebase_config.dart';

Future<void> configureApp() async {
  await AppInfo.init();
  await FirebaseConfig.configure();
  await GetStorage.init();
  await _loadEnv();
  await _configDependencies();
}

Future<void> _loadEnv() async {
  await Get.putAsync<EnvConfig>(
    () async {
      await dotenv.load();

      return EnvConfig(dotenv.env);
    },
  );
}

Future<void> _configDependencies() async {
  Get.put<AppController>(AppController(), permanent: true);
  Get.put<LanguageController>(LanguageController(), permanent: true);
  Get.lazyPut<NotificationController>(
    () => NotificationController(),
    fenix: true,
  );
}
