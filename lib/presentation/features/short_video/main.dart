import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'api/api_service.dart';
import 'utils/assert_image.dart';
import 'utils/const_res.dart';
import 'utils/font_res.dart';
import 'utils/my_loading/my_loading.dart';
import 'utils/session_manager.dart';
import 'view/chat_screen/chat_screen.dart';
import 'view/main/main_screen.dart';

SessionManager sessionManager = SessionManager();
String selectedLanguage = byDefaultLanguage;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // MobileAds.instance.initialize();
//   await Firebase.initializeApp();
//   await FlutterDownloader.initialize(ignoreSsl: true);
//   await sessionManager.initPref();
//   await _initAppTrackingTransparency();
//   selectedLanguage =
//       sessionManager.giveString(KeyRes.languageCode) ?? byDefaultLanguage;
//   runApp(const MyApp());
// }

class MyAppLive extends StatefulWidget {
  const MyAppLive({super.key});

  @override
  State<MyAppLive> createState() => _MyAppLiveState();
}

class _MyAppLiveState extends State<MyAppLive> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyLoading>(
      create: (context) => MyLoading(),
      child: Consumer<MyLoading>(
        builder: (context, MyLoading myLoading, child) {
          return const MyBubblyApp();
        },
      ),
    );
  }
}

// Platform messages are asynchronous, so we initialize in an async method.
Future<void> _initAppTrackingTransparency() async {
  final TrackingStatus status =
      await AppTrackingTransparency.trackingAuthorizationStatus;
  // If the system can show an authorization request dialog
  if (status == TrackingStatus.notDetermined) {
    // Request system's tracking authorization dialog
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
  await AppTrackingTransparency.getAdvertisingIdentifier();
}

class MyBubblyApp extends StatefulWidget {
  const MyBubblyApp({super.key});

  @override
  _MyBubblyAppState createState() => _MyBubblyAppState();
}

class _MyBubblyAppState extends State<MyBubblyApp> {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final SessionManager _sessionManager = SessionManager();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    _saveTokenUpdate();
    _getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) => Scaffold(
        body: Stack(
          children: [
            Center(
              child: Image(
                width: 225,
                image: AssetImage(myLoading.isDark
                    ? icLogoHorizontal
                    : icLogoHorizontalLight),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Text(
                  companyName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: FontRes.fNSfUiLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTokenUpdate() async {
    // flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions();

    await firebaseMessaging.requestPermission();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'bubbly', // id
        'Notification', // title
        enableLights: true,
        importance: Importance.max);

    FirebaseMessaging.onMessage.listen((message) {
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const initializationSettingsIOS = DarwinInitializationSettings();

      const initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);

      flutterLocalNotificationsPlugin.initialize(initializationSettings);
      final RemoteNotification? notification = message.notification;
      if (message.data['NotificationID'] == ChatScreen.notificationID) {
        return;
      }
      flutterLocalNotificationsPlugin.show(
        1,
        notification?.title,
        notification?.body,
        NotificationDetails(
          iOS: const DarwinNotificationDetails(
              presentSound: true, presentAlert: true, presentBadge: true),
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
          ),
        ),
      );
    });

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _getUserData() async {
    // final String? token = await firebaseMessaging.getToken();

    await _sessionManager.initPref();

    // _sessionManager.saveString(KeyRes.deviceToken, token);

    if (_sessionManager.getUser() != null &&
        _sessionManager.getUser()!.data != null) {
      SessionManager.userId = _sessionManager.getUser()!.data!.userId ?? -1;
      SessionManager.accessToken = _sessionManager.getUser()?.data?.token ?? '';
    }
    await ApiService().fetchSettingsData();

    Provider.of<MyLoading>(context, listen: false)
        .setUser(_sessionManager.getUser());
    !ConstRes.isDialog
        ? const SizedBox()
        : Provider.of<MyLoading>(context, listen: false)
            .setIsHomeDialogOpen(true);
    Provider.of<MyLoading>(context, listen: false).setSelectedItem(0);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false);
  }
}

// Overscroll color remove
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
