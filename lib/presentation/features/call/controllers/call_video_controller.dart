import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:easy_count_timer/easy_count_timer.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../core/extensions/call_session_controller_ext.dart';
import '../../../../core/utils/agora_voice_client.dart';
import '../../../../models/all.dart';
import '../../../../repositories/all.dart';
import '../../../../services/pip_inapp_service.dart';
import '../../../../services/sound_service.dart';
import '../../../base/base_controller.dart';
import '../../../common_controller.dart/all.dart';
import '../../../routing/routers/app_pages.dart';
import '../call.dart';
import '../events/refresh_call_view_event.dart';
import 'voice_record_controller.dart';

class CallController extends BaseController {
  @override
  void onInit() {
    initArgument();
    initListenCallStatus();
    initCountUpTimer();
    initSocketTranslate();

    super.onInit();
  }

  final appController = Get.find<AppController>();
  final callRepository = Get.find<CallRepository>();
  final userRepository = Get.find<UserRepository>();
  final soundService = Get.find<SoundService>();
  final chatRepository = Get.find<ChatRepository>();

  final Rx<CallStatusEnum> _callStatus = CallStatusEnum.connecting.obs;
  final RxMap<int, User> _users = RxMap();

  late ActionCall call;
  late CountTimerController countTimerController;
  late AgoraCustomClient agoraVoiceClient;
  late CallArgument callArgument;

  Duration totalCallDuration = Duration.zero;
  StreamSubscription? listenCallStatusSubscription;
  bool isCreateCall = false;
  bool isJoined = false;
  Conversation? conversation;
  late VoiceRecordController voiceRecordController;

  RxBool isRecord = false.obs;
  RxString statusTranslate = 'Press and hold to start translating'.obs;

  void initSocketTranslate() {
    chatRepository.onCallTranslate((p0) {
      if (p0 == 'speaking') {
        statusTranslate.value = '${getPartnerUser()!.fullName} is speaking...';
      } else if (p0 == 'transling') {
        statusTranslate.value = 'XINTEL is translating...';
      } else {
        statusTranslate.value = 'Press and hold to start translating';
        playAudio(p0);
        LogUtil.e(p0, name: runtimeType.toString());
      }
    });
  }

  void initListenCallStatus() {
    listenCallStatusSubscription = Get.find<EventBus>().on().listen((event) {
      if (event is RefreshCallViewEvent) {
        _callStatus.refresh();

        return;
      }

      if (event is FCMCallStatusEvent) {
        if (event.callId == callId(call)) {
          LogUtil.i(
            'initListenCallStatus: FCMCallStatusEnum ${event.status}',
            name: runtimeType.toString(),
          );

          switch (event.status) {
            case FCMCallStatusEnum.rejectCall:
              if (canRejectCall()) {
                leaveCall();
              }
              break;
            case FCMCallStatusEnum.endCall:
              if (canEndCall()) {
                leaveCall();
              }
              break;
            case FCMCallStatusEnum.startCall:
              break;
          }
        }
      }
    });
  }

  void cancelListenCallStatus() {
    listenCallStatusSubscription?.cancel();
  }

  void initArgument() {
    try {
      final argument = Get.arguments as CallArgument;
      callArgument = argument;
      if (argument is CreateCallArgument) {
        isCreateCall = true;
        _initCreateCallData(argument);
      }
      if (argument is JoinCallArgument) {
        isCreateCall = false;
        _initJoinCallData(argument);
      }
    } catch (e) {
      ViewUtil.showToast(
          title: 'Error', message: 'Error while getting call arguments');
      LogUtil.e(e.toString(), error: e, name: runtimeType.toString());
      Get.back();
    }
  }

  Future _initJoinCallData(CallArgument callArgument) async {
    try {
      call = callArgument.actionCall! as JoinCall;
      conversation = await chatRepository.getConversationById(
        conversationId: (call as JoinCall).call.chatChannelId,
      );
      await initUsers(conversation?.memberIds ?? []);
      callArgument.isVideo =
          (call as JoinCall).call.isVideo ?? callArgument.isVideo;
      callArgument.isGroup =
          (call as JoinCall).call.isGroup ?? callArgument.isGroup;
      await _initAgoraClient(call, callArgument);
    } catch (e) {
      unawaited(stopCall());
      ViewUtil.showToast(
          title: l10n.error__unknown, message: 'Error while join call');
      LogUtil.e(e.toString(), error: e, name: runtimeType.toString());
    }
  }

  Future _initCreateCallData(CallArgument callArgument) async {
    await runAction(
      action: () async {
        call = await callRepository.createCall(
          receiverIds: callArgument.receiverIds!,
          chatChannelId: callArgument.chatChannelId!,
          isGroup: callArgument.isGroup,
          isVideo: callArgument.isVideo,
          isTranslate: callArgument.isTranslate,
        );
        conversation = await chatRepository.getConversationById(
          conversationId: callArgument.chatChannelId!,
        );
        // override call data from server
        await initUsers(callArgument.receiverIds!);
        await _initAgoraClient(call, callArgument);

        return;
      },
      onError: (e) {
        LogUtil.e(e.toString(), error: e, name: runtimeType.toString());
        unawaited(leaveCall());
        if (e is ApiException) {
          Get.back();
          ViewUtil.showToast(
            title: e.serverError?.message ?? '',
            message: l10n.notification__title,
          );

          return;
        }
        ViewUtil.showToast(
          title: l10n.notification__title,
          message: l10n.global__error_has_occurred,
        );
        Get.back();
      },
    );
  }

  Future initUsers(List<int> ids) async {
    if (callStatus == CallStatusEnum.cancelled) {
      return;
    }
    users = {
      for (var element in await userRepository.getUsersByIds(ids))
        element.id: element,
    };
  }

  Future addNewInfoUser(int id) async {
    if (_users.containsKey(id)) {
      return;
    }
    final user = await userRepository.getUserById(id);
    _users[id] = user;
    _users.refresh();
  }

  String callId(ActionCall call) {
    if (call is CreateCall) {
      return call.callId;
    }
    if (call is JoinCall) {
      return call.call.id;
    }

    return '';
  }

  Future _initAgoraClient(ActionCall call, CallArgument callArgument) async {
    if (callStatus == CallStatusEnum.cancelled) {
      return;
    }
    agoraVoiceClient = AgoraCustomClient(
      agoraConnectionData: AgoraConnectionData(
        uid: appController.lastLoggedUser!.id,
        appId: call.appId,
        channelName: callId(call),
        tempToken: call.token,
        username: appController.lastLoggedUser!.email,
      ),
      agoraEventHandlers: AgoraRtcEventHandlers(
        onJoinChannelSuccess: onJoinChannelSuccess,
        onUserJoined: onUserJoined,
        onLeaveChannel: onLeaveChannel,
        onUserOffline: onUserOffline,
        onError: onError,
        onUserMuteVideo: (connection, remoteUid, muted) {
          LogUtil.i(
            'onUserMuteVideo: $muted $remoteUid',
            name: 'CallController',
          );
          // every body in call disable video
          final disableVideo = agoraVoiceClient.sessionController.value.users
              .every((element) =>
                  element.videoDisabled == null ||
                  element.videoDisabled == true);
          if (disableVideo &&
              agoraVoiceClient.sessionController.value.isLocalVideoDisabled) {
            agoraVoiceClient.engine.disableVideo();
            agoraVoiceClient.sessionController.callVoice();
          }
          if (!disableVideo) {
            agoraVoiceClient.engine.enableVideo();
            agoraVoiceClient.engine.enableAudioVolumeIndication(
              interval: 200,
              smooth: 3,
              reportVad: true,
            );
            agoraVoiceClient.sessionController.callVideo();
          }
        },
      ),
      callType: callArgument.isVideo ? CallType.video : CallType.voice,
    );
    await agoraVoiceClient.initialize();
    voiceRecordController = VoiceRecordController(agoraVoiceClient.engine);
    await voiceRecordController.initialize();
  }

  void initCountUpTimer() {
    countTimerController = CountTimerController();
  }

  void onCountUpTimerEnd() {
    if (kDebugMode) {
      print(totalCallDuration);
    }
  }

  void onChangeStatusCall(CallStatusEnum status) {
    switch (status) {
      case CallStatusEnum.connecting:
        countTimerController.restart();
        break;
      case CallStatusEnum.ringing:
        countTimerController.restart();
        soundService.playSoundCalling();
        break;
      case CallStatusEnum.calling:
        countTimerController.start();
        soundService.stopSound();
        break;
      case CallStatusEnum.ended:
        totalCallDuration = countTimerController.duration;
        countTimerController.pause();
        soundService.playSoundEndCall();
        break;
      case CallStatusEnum.rejected:
        countTimerController.pause();
        soundService.playSoundEndCall();
        break;
      case CallStatusEnum.cancelled:
        countTimerController.pause();
        soundService.playSoundEndCall();
        break;
    }
    CallKitManager.instance.callStatus = status;
    callStatus = status;
  }

  bool canLeave() {
    // have another user in call
    return agoraVoiceClient.users
        .any((element) => element != agoraVoiceClient.agoraConnectionData.uid);
  }

  bool canJoinChanel() {
    return !isJoined;
  }

  bool canEndCall() {
    // end call when joined call
    return isJoined &&
        callStatus != CallStatusEnum.ended &&
        callStatus != CallStatusEnum.rejected;
  }

  bool canRejectCall() {
    // reject call when don't join call
    return !isJoined &&
        callStatus != CallStatusEnum.rejected &&
        callStatus != CallStatusEnum.ended;
  }

  bool canCancelCall() {
    // reject call when don't join call
    return !isJoined && (callStatus == CallStatusEnum.connecting);
  }

  Future readyCall() async {
    if (isCreateCall) {
      await CallKitManager.instance.readyCall(callId(call));
    }
  }

  Future joinCall() async {
    isJoined = true;
    soundService.stopSound();
    await CallKitManager.instance.joinCallSuccess(callId(call));
  }

  Future leaveCall() async {
    try {
      await agoraVoiceClient.release();
      //ensure call cancel when agora leave action doesn't work
      await stopCall();
    } catch (e) {
      LogUtil.e(e.toString(), error: e, name: runtimeType.toString());
      await stopCall();
      await agoraVoiceClient.engine.release(sync: true);
    }
  }

  Future _endCall() async {
    if (callStatus == CallStatusEnum.ended) {
      return;
    }
    LogUtil.i('endCall', name: runtimeType.toString());
    final callId = agoraVoiceClient.agoraConnectionData.channelName;

    onChangeStatusCall(CallStatusEnum.ended);
    await CallKitManager.instance.leaveCall(callId);
  }

  Future _rejectCall() async {
    LogUtil.i('rejectCall', name: runtimeType.toString());
    onChangeStatusCall(CallStatusEnum.rejected);
    await CallKitManager.instance.cancelCall(callId(call));
  }

  Future _cancelCall() async {
    LogUtil.i('_cancelCall', name: runtimeType.toString());
    onChangeStatusCall(CallStatusEnum.cancelled);
    await CallKitManager.instance.cancelCall(callId(call));
  }

  Future stopCall() async {
    try {
      // remote user leave call
      // handle off pip
      if (CallKitManager.instance.isOnPipView) {
        await PipInAppService.of(Get.context!).dismissPIP();
        unawaited(Get.toNamed(Routes.call));
        CallKitManager.instance.offPipView();
      }
      if (canCancelCall()) {
        return await _cancelCall();
      }
      // check call duplicate
      // only call one time
      if (canRejectCall()) {
        return await _rejectCall();
      }

      if (canEndCall()) {
        return await _endCall();
      }
    } catch (_) {
      LogUtil.e(_.toString(), error: _, name: runtimeType.toString());
    }
  }

  bool isVoiceCall() {
    return !callArgument.isVideo;
  }

  CallStatusEnum get callStatus => _callStatus.value;

  set callStatus(CallStatusEnum value) {
    _callStatus.value = value;
  }

  Map<int, User> get users => _users;

  set users(Map<int, User> values) {
    _users.assignAll(values);
  }

  Future onJoinChannelSuccess(RtcConnection connection, int elapsed) async {
    LogUtil.i(
      'onJoinChannelSuccess------------------------------------------',
      name: runtimeType.toString(),
    );
    if (callStatus == CallStatusEnum.connecting) {
      onChangeStatusCall(CallStatusEnum.ringing);
      await readyCall();
    }
    // join chanel when ROLE is receiver call
    if (!isCreateCall && canJoinChanel()) {
      await joinCall();
    }
    if (isVoiceCall()) {
      // trigger video
      await agoraVoiceClient.engine.muteLocalVideoStream(true);
    }
  }

  Future onUserJoined(
      RtcConnection connection, int remoteUid, int elapsed) async {
    LogUtil.i(
      'onUserJoined------------------------------------------',
      name: runtimeType.toString(),
    );
    if (remoteUid != agoraVoiceClient.agoraConnectionData.uid) {
      // join chanel when ROLE is caller and have another user in call
      if (canJoinChanel()) {
        await joinCall();
      }
      // case for call group
      // user role is receiver
      // has new user join call then get info to display info user
      if (!isCreateCall) {
        await addNewInfoUser(remoteUid);
      }
      if (callStatus != CallStatusEnum.calling) {
        onChangeStatusCall(CallStatusEnum.calling);
      }
      if (isVoiceCall()) {
        // trigger video
        await agoraVoiceClient.engine.disableVideo();
      }
    }
  }

  Future onLeaveChannel(RtcConnection connection, RtcStats stats) async {
    LogUtil.i(
      'onLeaveChannel------------------------------------------',
      name: runtimeType.toString(),
    );
    await stopCall();
  }

  void onUserOffline(
      RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
    //when remote user leave the call
    LogUtil.i(
      'onUserOffline------------------------------------------',
      name: runtimeType.toString(),
    );
    // auto leave when room have only me
    if (agoraVoiceClient.users.isEmpty) {
      leaveCall();
    }
  }

  void onError(ErrorCodeType err, String msg) {
    LogUtil.i(
      'onError------------------------------------------',
      name: runtimeType.toString(),
    );
    leaveCall();
  }

  @override
  void onClose() {
    leaveCall().then((value) => agoraVoiceClient.engine.release(sync: true));
    cancelListenCallStatus();
    Get.find<SoundService>().stopSound();
    super.onClose();
  }

  void onCloseClick() {
    leaveCall();
    if (Get.currentRoute == Routes.call) {
      Get.back();
    }
  }

  User? getPartnerUser() {
    try {
      final user = users.values.firstWhere(
        (element) => element.id != appController.currentUser.id,
      );

      return user;
    } catch (_) {
      return null;
    }
  }

  Future pipClick(BuildContext context) async {
    CallKitManager.instance.onPipView(
      context,
      onAfterPipViewOff: () {
        agoraVoiceClient.sessionController.value =
            agoraVoiceClient.sessionController.value.copyWith(
          visible: true,
          showLocalCameraview: true,
        );
      },
      onBeforePipViewOn: () {
        agoraVoiceClient.sessionController.value =
            agoraVoiceClient.sessionController.value.copyWith(
          visible: false,
          showLocalCameraview: false,
        );
      },
    );
  }

  void startRecording() {
    voiceRecordController.startRecording();
    chatRepository.sendCallTranslate(
      roomId: conversation!.id,
      data: 'speaking',
    );
  }

  void stopRecording() {
    final user = getPartnerUser();
    String? defaultLanguage;
    if (currentUser.talkLanguage == null) {
      defaultLanguage = languages.firstWhere(
          (map) => map['langCode'] == talkLanguage,
          orElse: () => {'talkCode': 'en-US'})['talkCode'];
    }
    voiceRecordController.stopRecording(
      conversation!.id,
      42,
      currentUser.talkLanguage ?? defaultLanguage ?? '',
      user!.talkLanguage ?? 'en-US',
    );
    chatRepository.sendCallTranslate(
      roomId: conversation!.id,
      data: 'transling',
    );
  }

  void playAudio(String path) {
    voiceRecordController.playAudio(path, conversation!.memberIds.first);
  }
}

class CallArgument {
  String? chatChannelId;
  List<int>? receiverIds;
  bool isGroup;
  bool isVideo;
  ActionCall? actionCall;
  bool isTranslate;

  CallArgument({
    required this.isGroup,
    required this.isVideo,
    required this.isTranslate,
    this.chatChannelId,
    this.receiverIds,
    this.actionCall,
  });
}

class CreateCallArgument extends CallArgument {
  CreateCallArgument({
    required String chatChannelId,
    required List<int> receiverIds,
    required bool isGroup,
    required bool isVideo,
    required bool isTranslate,
  }) : super(
          chatChannelId: chatChannelId,
          receiverIds: receiverIds,
          isGroup: isGroup,
          isVideo: isVideo,
          isTranslate: isTranslate,
        );
}

class JoinCallArgument extends CallArgument {
  JoinCallArgument({
    required String chatChannelId,
    required JoinCall createCall,
    required bool isVideo,
    required bool isGroup,
    required bool isTranslate,
  }) : super(
          chatChannelId: chatChannelId,
          actionCall: createCall,
          isVideo: isVideo,
          isGroup: isGroup,
          isTranslate: isTranslate,
        );
}
