// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/all.dart';
import '../../../../core/utils/parse_util.dart';
import '../../../../models/join_call.dart';
import '../../../../repositories/call/call_repository.dart';
import '../../../../repositories/call_background_repository.dart';
import '../../../../services/pip_inapp_service.dart';
import '../../../routing/routers/app_pages.dart';
import '../call.dart';

class CallKitManager {
  CallRepository? callRepository;

  static CallKitManager get instance => _getInstance();

  static CallKitManager? _instance;
  static String TAG = 'CallKitManager';
  static const int VIDEOCALL = 1;
  static const int AUDIOCALL = 0;
  String? currentCallId;
  String? callControllerId;
  CallStatusEnum? callStatus;
  bool _pipView = false;

  static CallKitManager _getInstance() {
    return _instance ??= CallKitManager._internal();
  }

  factory CallKitManager() => _getInstance();

  CallKitManager._internal();

  void init() {
    ConnectycubeFlutterCallKit.instance.init(
      onCallAccepted: _onCallAccepted,
      onCallRejected: _onCallRejected,
      onCallIncoming: _onCallIncoming,
      icon: Platform.isAndroid ? 'default_avatar' : 'CallkitIcon',
      color: '#07711e',
      // ringtone: Platform.isAndroid ? 'custom_ringtone' : 'custom_ringtone.caf'
    );
    if (Platform.isIOS) {
      ConnectycubeFlutterCallKit.onCallMuted = _onCallMuted;
    }
    ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated =
        onCallRejectedWhenTerminated;
  }

  Future checkCallFromAppTerminatedState() async {
    final lastCallId = await ConnectycubeFlutterCallKit.getLastCallId();
    if (lastCallId == null || lastCallId.isEmpty) {
      return;
    }
    final callState =
        await ConnectycubeFlutterCallKit.getCallState(sessionId: lastCallId);
    LogUtil.i(
      'checkCallFromAppTerminatedState:callState $callState',
      name: TAG,
    );
    final callData =
        await ConnectycubeFlutterCallKit.getCallData(sessionId: lastCallId);
    if (callData != null) {
      LogUtil.i(
        'checkCallFromAppTerminatedState:callData $callData',
        name: TAG,
      );
      if (callState == CallState.ACCEPTED) {
        await joinCall(
          chanelId: callData['session_id'],
          // isVideo: int.tryParse(callData['call_type']) == VIDEOCALL,
        );
      } else if (callState == CallState.PENDING) {
        try {
          final callEvent = CallEvent(
            sessionId: callData['session_id'],
            callType: int.tryParse(callData['call_type'] ?? '0') ?? 0,
            callerId: int.tryParse(callData['caller_id'] ?? '0') ?? 0,
            callerName: callData['caller_name'] ?? '',
            opponentsIds: const {},
          );
          await _onCallIncoming(callEvent);
        } catch (e) {
          print(e);
        }
      } else if (callState == CallState.REJECTED) {
        await processCallFinished(lastCallId);
      }
    }
  }

  Future<void> processCallFinished(String uuid) async {
    callControllerId = null;
    await ConnectycubeFlutterCallKit.reportCallEnded(sessionId: uuid);
    await ConnectycubeFlutterCallKit.clearCallData(sessionId: uuid);
    await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(
      isVisible: false,
    );
    await turnOffKeepScreenOn();
  }

  /// Event Listener Callbacks for 'connectycube_flutter_call_kit'
  ///
  Future<void> _onCallMuted(bool mute, String uuid) async {
    // await ConnectycubeFlutterCallKit.reportCallMuted(
    //     sessionId: uuid, muted: mute);
  }

  void muteCall(String sessionId, bool mute) {
    ConnectycubeFlutterCallKit.reportCallMuted(
        sessionId: sessionId, muted: mute);
  }

  Future<void> _onCallAccepted(CallEvent callEvent) async {
    LogUtil.i('_onCallAccepted: ${callEvent.toJson()}', name: TAG);
    await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);
    await joinCall(chanelId: callEvent.sessionId);
  }

  Future<void> _onCallRejected(CallEvent callEvent) async {
    final callState = await ConnectycubeFlutterCallKit.getCallState(
      sessionId: callEvent.sessionId,
    );
    await closeInComingCallPage();
    if (callState == CallState.ACCEPTED) {
      Get.find<EventBus>().fire(
        FCMCallStatusEvent(callEvent.sessionId, FCMCallStatusEnum.endCall),
      );
      await leaveCall(callEvent.sessionId);
    }
    if (callState == CallState.PENDING || callState == CallState.REJECTED) {
      try {
        if (Get.currentRoute == Routes.call) {
          Get.find<EventBus>().fire(
            FCMCallStatusEvent(callEvent.sessionId, FCMCallStatusEnum.endCall),
          );

          return;
        }
      } catch (_) {}
      Get.find<EventBus>().fire(
        FCMCallStatusEvent(callEvent.sessionId, FCMCallStatusEnum.rejectCall),
      );
      // handle close incoming call page
      await cancelCall(callEvent.sessionId);
    }
    unawaited(
      ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: false),
    );
    await ConnectycubeFlutterCallKit.clearCallData(
      sessionId: callEvent.sessionId,
    );
    LogUtil.i('_onCallRejected: ${callEvent.toJson()}', name: TAG);
  }

  Future closeInComingCallPage() async {
    if (Get.currentRoute == Routes.inComingCall) {
      Get.back();
    }
  }

  Future _onCallIncoming(CallEvent event) async {
    LogUtil.i('_onCallIncoming: ${event.toJson()}', name: TAG);
    if (Get.currentRoute == Routes.call) {
      unawaited(Get.offNamed(Routes.inComingCall, arguments: event));

      return;
    }
    unawaited(Get.toNamed(Routes.inComingCall, arguments: event));
  }

  Future fcmCallIncoming(Map<String, dynamic> fcmData) async {
    final CallEvent event = ParseUtil.parseCallEvent(fcmData);
    LogUtil.i('fcmCallIncoming: ${event.toJson()}', name: TAG);
    // await Get.toNamed(Routes.inComingCall, arguments: event);
  }

  Future createCall({
    required String chatChannelId,
    required List<int> receiverIds,
    required bool isGroup,
    required bool isVideo,
    required bool isTranslate,
  }) async {
    if (_pipView) {
      ViewUtil.showToast(
        title: Get.context!.l10n.notification__title,
        message: Get.context!.l10n.user_in_call,
      );

      return;
    }
    LogUtil.i('createCall: chatChannelId:$chatChannelId', name: TAG);
    callControllerId =
        'call_controller_${DateTime.now().millisecondsSinceEpoch}';

    return Get.toNamed(
      Routes.call,
      arguments: CreateCallArgument(
        chatChannelId: chatChannelId,
        receiverIds: receiverIds,
        isGroup: isGroup,
        isVideo: isVideo,
        isTranslate: isTranslate,
      ),
    );
  }

  Future joinCall({
    required String chanelId,
  }) async {
    if (_pipView) {
      ViewUtil.showToast(
        title: Get.context!.l10n.notification__title,
        message: Get.context!.l10n.user_in_call,
      );

      return;
    }
    callControllerId = chanelId;
    LogUtil.i('joinCall: $chanelId', name: TAG);
    callRepository ??= Get.find<CallRepository>();
    try {
      final JoinCall createCall =
          await callRepository!.generateToken(callId: chanelId);
      final argument = JoinCallArgument(
        chatChannelId: createCall.call.chatChannelId,
        createCall: createCall,
        isGroup: createCall.call.isGroup!,
        isVideo: createCall.call.isVideo!,
        isTranslate: createCall.call.isTranslate!,
      );
      // check if already in call page
      if (Get.currentRoute == Routes.call ||
          Get.currentRoute == Routes.inComingCall) {
        return Get.offAndToNamed(Routes.call, arguments: argument);
      }

      return Get.toNamed(Routes.call, arguments: argument);
    } catch (e) {
      LogUtil.e(e.toString(), error: e, name: TAG);

      await closeInComingCallPage();
      await cancelCall(chanelId);
      if (e is ApiException) {
        ViewUtil.showToast(
          title: e.serverError?.message ?? '',
          message: Get.context!.l10n.notification__title,
        );

        return;
      }
    }
  }

  Future joinCallSuccess(String chanelId) async {
    LogUtil.i('joinSuccess: $chanelId', name: TAG);
    currentCallId = chanelId;
    await _updateAction(chanelId, CallActionEnum.join);
  }

  Future leaveCall(String chanelId) async {
    LogUtil.i('leaveCall: $chanelId', name: TAG);
    currentCallId = null;
    await _updateAction(chanelId, CallActionEnum.leave);
    await processCallFinished(chanelId);
  }

  Future cancelCall(String chanelId) async {
    LogUtil.i('cancelCall: $chanelId', name: TAG);
    currentCallId = null;
    await _updateAction(chanelId, CallActionEnum.cancel);
    await processCallFinished(chanelId);
  }

  Future _updateAction(String callId, CallActionEnum action) async {
    LogUtil.i('_updateAction: $action $callId', name: TAG);
    callRepository ??= Get.find<CallRepository>();
    try {
      await callRepository!.updateCallAction(
        callId: callId,
        action: action,
      );
    } catch (e) {
      LogUtil.e(e.toString(), error: e, name: TAG);
    }
  }

  Future readyCall(String callId) async {
    LogUtil.i('readyCall: $callId', name: TAG);
    callRepository ??= Get.find<CallRepository>();
    try {
      await callRepository!.readyCall(callId: callId);
    } catch (e) {
      LogUtil.e(e.toString(), error: e, name: TAG);
    }
  }

  Future turnOnKeepScreenOn() async {
    try {
      LogUtil.i('turnOnKeepScreenOn', name: TAG);
      if (!await WakelockPlus.enabled) {
        await WakelockPlus.enable();
      }
    } catch (e) {
      LogUtil.e(e.toString(), error: e, name: TAG);
    }
  }

  Future turnOffKeepScreenOn() async {
    try {
      LogUtil.i('turnOffKeepScreenOn', name: TAG);
      if (await WakelockPlus.enabled) {
        await WakelockPlus.disable();
      }
    } catch (e) {
      LogUtil.e(e.toString(), error: e, name: TAG);
    }
  }

  /// This method is used to enable Picture-in-Picture (PiP) mode for the application.
  ///
  /// It first sets the `_pipView` flag to `true` indicating that the app is in PiP mode.
  /// Then it checks if the current route is the call route, if so, it navigates back.
  ///
  /// After that, it calls the `showPIP` method of the `PipInAppService` to actually enable the PiP mode.
  /// The `showPIP` method takes a `child` widget which will be shown in the PiP window.
  /// In this case, it's the `CallView` widget.
  ///
  /// The `showPIP` method also takes a callback `onPIPClick` which will be executed when the PiP window is clicked.
  /// In the callback, it checks if the `callControllerId` is `null`, if not, it navigates to the call route and turns off the PiP mode.
  ///
  /// @param context The build context at which this method is called.
  void onPipView(
    BuildContext context, {
    Function()? onBeforePipViewOn,
    Function()? onAfterPipViewOff,
  }) {
    if (_pipView) return;
    _pipView = true;
    if (Get.currentRoute == Routes.call) {
      Get.back();
    }
    if (callControllerId == null) {
      offPipView();

      return;
    }
    onBeforePipViewOn?.call();

    PipInAppService.of(context).showPIP(
      child: const CallView(),
      onPIPClick: () {
        if (callControllerId == null) {
          return;
        }
        onAfterPipViewOff?.call();
        Get.toNamed(Routes.call);
        offPipView();
      },
    );
  }

  void offPipView() {
    _pipView = false;
  }

  bool get canCloseCallController => !_pipView && callControllerId == null;

  bool get isOnPipView => _pipView;
}

@pragma('vm:entry-point')
Future<void> onCallRejectedWhenTerminated(CallEvent callEvent) async {
  // ignore: avoid_print
  print(
      '[PushNotificationsManager][onCallRejectedWhenTerminated] callEvent: $callEvent');
  // try {
  final callBackgroundRepository = CallBackgroundRepository();
  await callBackgroundRepository.updateCallAction(
    callId: callEvent.sessionId,
    action: CallActionEnum.cancel,
  );
  // ignore: avoid_print
  print(
      '[PushNotificationsManager][onCallRejectedWhenTerminated] Success callEvent: $callEvent');
  // } catch (e) {
  //   print(e);
  // }
}
