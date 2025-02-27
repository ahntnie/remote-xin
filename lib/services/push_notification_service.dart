import 'dart:convert';
import 'dart:io';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../core/all.dart';
import '../data/preferences/app_preferences.dart';
import '../models/notification/notification_payload.dart';
import '../presentation/common_controller.dart/all.dart';
import '../presentation/features/all.dart';
import '../presentation/features/call/call.dart';
import '../presentation/routing/routers/app_pages.dart';
import '../repositories/auth/auth_repo.dart';

class PushNotificationService extends GetxService with LogMixin {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final eventBus = Get.find<EventBus>();

  @override
  void onInit() {
    initFirebaseMessaging();
    super.onInit();
  }

  Future<String?> getVoipToken() async {
    if (Platform.isIOS) {
      return await ConnectycubeFlutterCallKit.getToken();
    }

    return null;
  }

  Future<void> initFirebaseMessaging() async {
    final token = await _firebaseMessaging.getToken();
    final String? viopToken = await getVoipToken();
    final String? accessToken =
        await Get.find<AppPreferences>().getAccessToken();

    if (accessToken != null) {
      await _sendTokenToServer(token, viopToken);
    }

    if (!Get.find<AppController>().isLogged) {
      return;
    }

    await _requestPermission();

    _firebaseMessaging.onTokenRefresh.listen((token) async {
      logDebug('onTokenRefresh: $token');
      await _sendTokenToServer(token, await getVoipToken());
    });
    await _firebaseMessaging.getInitialMessage().then((event) {
      if (event != null) {
        final Map<String, dynamic>? message = event.data['message'] != null
            ? jsonDecode(event.data['message'] as String)
            : null;
        if (message != null) {
          _handleOnTapNewMessage(message);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      announcement: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logDebug('Permission granted');
    } else {
      logDebug('Permission denied or not granted');
    }
  }

  Future<void> _sendTokenToServer(String? token, String? voipToken) async {
    if (token == null) {
      return;
    }

    return Get.find<AuthRepository>().updateFCMToken(token, voipToken);
  }

  void _onMessageOpenedApp(RemoteMessage event) {
    logInfo('onMessageOpenedApp: ${event.toMap()}');

    final Map<String, dynamic>? message = event.data['message'] != null
        ? jsonDecode(event.data['message'] as String)
        : null;
    if (message != null) {
      _handleOnTapNewMessage(message);
    }
  }

  void _onMessage(RemoteMessage event) {
    logInfo('onMessage: ${event.toMap()}');
    // ignore message when call coming
    if (event.data['signal_type'] != null) {
      final signalType =
          (event.data['signal_type'] as String?).getFCMCallStatusEnumValue();
      if (signalType != null) {
        LogUtil.i(
          'onMessage: signalType: $signalType',
          name: runtimeType.toString(),
        );

        eventBus.fire(
          FCMCallStatusEvent(
            event.data['session_id'],
            signalType,
          ),
        );
      }

      return;
    }

    final title = event.notification?.title ?? '';
    final body = event.notification?.body ?? '';

    final Map<String, dynamic>? message = event.data['message'] != null
        ? jsonDecode(event.data['message'] as String)
        : null;

    // Check if the notification is not from chat
    if ((message?['chatRoomId'] as String?) == null) {
      Get.find<NotificationController>().increaseUnreadNotificationsCount();
    }

    ViewUtil.showToast(
      title: title,
      message: body,
      onTapped: () {
        if (message != null) {
          return _handleOnTapNewMessage(message);
        }
      },
    );
  }

  void _handleOnTapNewMessage(Map<String, dynamic> data) {
    final conversationId = data['chatRoomId'] as String?;

    if (conversationId != null) {
      return _openChatRoom(conversationId);
    }

    try {
      final notificationData = BaseNotificationPayload.fromJson(data);

      Get.find<NotificationController>().decreaseUnreadNotificationsCount();

      Get.find<NotificationController>()
          .handleNotificationPayload(notificationData);
    } catch (e) {
      logError('Error parsing notification data: $e');
    }
  }

  void _openChatRoom(String conversationId) {
    if (Get.currentRoute == Routes.chatHub) {
      final controller = Get.find<ChatHubController>();

      if (controller.conversation.id != conversationId) {
        controller.reloadWithNewConversationId(conversationId);

        return;
      }
    }

    Get.toNamed(
      Routes.chatHub,
      arguments: ChatHubArguments(
        conversationId: conversationId,
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage event) async {
  // ignore: avoid_print
  print('[PushNotificationsManager][onBackgroundMessage] callEvent: $event');
  // try {
  if (event.data['signal_type'] != null) {
    final signalType =
        (event.data['signal_type'] as String?).getFCMCallStatusEnumValue();
    if (signalType != null) {
      LogUtil.i(
        'onMessage: signalType: $signalType',
        name: 'PushNotificationsManager',
      );
      if (signalType == FCMCallStatusEnum.rejectCall ||
          signalType == FCMCallStatusEnum.endCall) {
        await ConnectycubeFlutterCallKit.reportCallEnded(
          sessionId: event.data['session_id'],
        );
      }
    }
  }
  // ignore: avoid_print
  print(
    '[PushNotificationsManager][onBackgroundMessage] Success callEvent: $event',
  );
  // } catch (e) {
  //   print(e);
  // }
}
