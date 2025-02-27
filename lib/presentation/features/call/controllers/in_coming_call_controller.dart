import 'dart:async';
import 'dart:io';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:event_bus/event_bus.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../../repositories/all.dart';
import '../../../base/all.dart';
import '../../../routing/routers/app_pages.dart';
import '../call.dart';

class InComingCallController extends BaseController {
  late CallEvent callEvent;
  final userService = Get.find<UserRepository>();
  final Rx<User?> _caller = Rx<User?>(null);
  StreamSubscription? listenCallStatusSubscription;

  @override
  void onInit() {
    try {
      callEvent = Get.arguments as CallEvent;
    } catch (e) {
      LogUtil.e(e.toString(), name: runtimeType.toString());
      ViewUtil.showToast(
        title: l10n.global__error_has_occurred,
        message: 'Missing arguments',
      );
    }
    initCallerData();
    initListenCallStatus();
    super.onInit();
  }

  @override
  void onClose() {
    cancelListenCallStatus();
    super.onClose();
  }

  void initListenCallStatus() {
    listenCallStatusSubscription =
        Get.find<EventBus>().on<FCMCallStatusEvent>().listen((event) {
      if (event.callId == callEvent.sessionId) {
        LogUtil.i(
          'initListenCallStatus: FCMCallStatusEnum ${event.status}',
          name: runtimeType.toString(),
        );

        switch (event.status) {
          case FCMCallStatusEnum.rejectCall:
            if (Get.currentRoute == Routes.inComingCall) {
              onDecline(inRemoteReject: true);
            }
            break;
          case FCMCallStatusEnum.endCall:
            if (Get.currentRoute == Routes.inComingCall) {
              onDecline(inRemoteReject: true);
            }
            break;
          default:
            break;
        }
      }
    });
  }

  void cancelListenCallStatus() {
    listenCallStatusSubscription?.cancel();
  }

  Future initCallerData() async {
    try {
      final user = await userService.getUserById(callEvent.callerId);
      _caller.value = user;
    } catch (e) {
      LogUtil.e(e.toString(), name: runtimeType.toString());
      ViewUtil.showToast(
        title: l10n.global__error_has_occurred,
        message: l10n.error__user_not_found,
      );
    }
  }

  bool isVideoCall() {
    return callEvent.callType == CallKitManager.VIDEOCALL;
  }

  bool isVoiceCall() {
    return callEvent.callType == CallKitManager.AUDIOCALL;
  }

  void onDecline({bool inRemoteReject = false}) {
    runAction(
      action: () async {
        unawaited(ConnectycubeFlutterCallKit.reportCallEnded(
          sessionId: callEvent.sessionId,
        ));
        if (Platform.isAndroid && !inRemoteReject) {
          await CallKitManager.instance.cancelCall(callEvent.sessionId);
        }
        Get.back(closeOverlays: true);
      },
      onError: (exception) {
        Get.back(closeOverlays: true);
      },
    );
  }

  void onAccept() {
    runAction(
      action: () async {
        unawaited(ConnectycubeFlutterCallKit.reportCallAccepted(
          sessionId: callEvent.sessionId,
        ));
        if (Platform.isAndroid) {
          await CallKitManager.instance.joinCall(
            chanelId: callEvent.sessionId,
            // isVideo: isVideoCall(),
          );
        }
      },
      onError: (exception) {
        onDecline();
      },
    );
  }

  User? get caller => _caller.value;

  set caller(User? value) {
    _caller.value = value;
  }
}
