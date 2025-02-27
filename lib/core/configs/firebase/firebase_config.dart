import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

class FirebaseConfig {
  const FirebaseConfig._();

  static Future<void> configure() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<NotificationSettings>
      firebaseMessagingRequestPermission() async {
    return await FirebaseMessaging.instance.requestPermission(
      announcement: true,
    );
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
