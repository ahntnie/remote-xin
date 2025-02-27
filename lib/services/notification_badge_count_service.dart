import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:get/get.dart';

import '../presentation/features/chat/dashboard/controllers/dashboard_controller.dart';
import '../presentation/features/notification/notification_controller.dart';

class NotificationBadgeCountService extends GetxService {
  final _notificationController = Get.find<NotificationController>();
  final _chatDashboardController = Get.find<ChatDashboardController>();

  int _currentUnreadMessageCount = 0;
  int _currentUnreadNotificationsCount = 0;

  @override
  void onInit() {
    // get the initial badge count
    _getInitialBadgeCount();

    // listen to changes in unread message count and unread notifications count
    _listenToChanges();

    super.onInit();
  }

  void _updateBadgeCount({
    required int unreadMessageCount,
    required int unreadNotificationsCount,
  }) {
    _currentUnreadMessageCount = unreadMessageCount;
    _currentUnreadNotificationsCount = unreadNotificationsCount;

    final badgeCount = unreadMessageCount + unreadNotificationsCount;

    _setBadgeCount(badgeCount);
  }

  Future<void> _getInitialBadgeCount() async {
    final unreadMessageCount = _chatDashboardController.unReadMessageCount;
    final unreadNotificationsCount =
        _notificationController.unreadNotificationsCount;

    _updateBadgeCount(
      unreadMessageCount: unreadMessageCount,
      unreadNotificationsCount: unreadNotificationsCount,
    );
  }

  void _listenToChanges() {
    // Listen to changes in unread message count
    _chatDashboardController.unReadMessageCountStream
        .listen((unreadMessageCount) {
      _updateBadgeCount(
        unreadMessageCount: unreadMessageCount,
        unreadNotificationsCount: _currentUnreadNotificationsCount,
      );
    });

    // Listen to changes in unread notifications count
    _notificationController.unreadNotificationsCountStream
        .listen((unreadNotificationsCount) {
      _updateBadgeCount(
        unreadMessageCount: _currentUnreadMessageCount,
        unreadNotificationsCount: unreadNotificationsCount,
      );
    });
  }

  Future<void> _setBadgeCount(int badgeCount) async {
    try {
      await FlutterDynamicIcon.setApplicationIconBadgeNumber(badgeCount);
    } catch (e) {
      debugPrint('Error setting badge count: $e');
    }
  }
}
