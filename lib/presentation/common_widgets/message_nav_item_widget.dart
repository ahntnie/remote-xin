import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../repositories/all.dart';
import '../features/all.dart';
import '../resource/resource.dart';

class MessageNavItemWidget extends StatefulWidget {
  final Widget child;

  const MessageNavItemWidget({
    required this.child,
    super.key,
  });

  @override
  State<MessageNavItemWidget> createState() => _MessageNavItemWidgetState();
}

class _MessageNavItemWidgetState extends State<MessageNavItemWidget> {
  StreamSubscription? _streamSubscription;
  final chatRepo = Get.find<ChatRepository>();

  final RxBool _hasUnreadMessage = false.obs;
  bool get hasUnreadMessage => _hasUnreadMessage.value;

  @override
  void initState() {
    listenToUnreadMessage();
    super.initState();
  }

  void listenToUnreadMessage() {
    _streamSubscription = Get.find<ChatDashboardController>()
        .unReadMessageCountStream
        .listen((unreadMessageCount) {
      _hasUnreadMessage.value = unreadMessageCount > 0;
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Obx(
          () => hasUnreadMessage
              ? Positioned(
                  right: 20.w,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    width: 10.w,
                    height: 10.w,
                    decoration: const BoxDecoration(
                      color: AppColors.reacted,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}
