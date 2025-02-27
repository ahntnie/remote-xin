import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit/controllers/rtc_buttons.dart';
import 'package:agora_uikit/controllers/session_controller.dart';
import 'package:flutter/services.dart';

import '../extensions/call_session_controller_ext.dart';

/// [AgoraCustomClient] is the main class in this VideoUIKit. It is used to initialize our [RtcEngine], add the list of user permissions, define the channel properties and use extend the [RtcEngineEventHandler] class.
class AgoraCustomClient extends AgoraClient {
  AgoraCustomClient({
    required this.agoraConnectionData,
    required this.callType,
    this.enabledPermission,
    this.agoraChannelData,
    this.agoraEventHandlers,
    this.agoraRtmClientEventHandler,
    this.agoraRtmChannelEventHandler,
  })  : _initialized = false,
        super(
          agoraConnectionData: agoraConnectionData,
          agoraEventHandlers: agoraEventHandlers,
          agoraRtmChannelEventHandler: agoraRtmChannelEventHandler,
          agoraRtmClientEventHandler: agoraRtmClientEventHandler,
          agoraChannelData: agoraChannelData,
          enabledPermission: enabledPermission,
        );

  /// [AgoraConnectionData] is a class used to store all the connection details to authenticate your account with the Agora SDK.
  @override
  final AgoraConnectionData agoraConnectionData;

  @override

  /// [enabledPermission] is a list of permissions that the user has to grant to the app. By default the UIKit asks for the camera and microphone permissions for every broadcaster that joins the channel.
  final List<Permission>? enabledPermission;
  @override

  /// [AgoraChannelData] is a class that contains all the Agora channel properties.
  final AgoraChannelData? agoraChannelData;
  @override

  /// [AgoraRtcEventHandlers] is a class that contains all the Agora RTC event handlers. Use it to add your own functions or methods.
  final AgoraRtcEventHandlers? agoraEventHandlers;
  @override

  /// [AgoraRtmClientEventHandlers] is a class that contains all the Agora RTM Client event handlers. Use it to add your own functions or methods.
  final AgoraRtmClientEventHandler? agoraRtmClientEventHandler;
  @override

  /// [AgoraRtmChannelEventHandlers] is a class that contains all the Agora RTM channel event handlers. Use it to add your own functions or methods.
  final AgoraRtmChannelEventHandler? agoraRtmChannelEventHandler;

  // This is our "state" object that the UI Kit works with
  final SessionController _sessionController = SessionController();

  //
  final CallType callType;

  static const MethodChannel _channel = MethodChannel('agora_uikit');
  bool _initialized = false;

  /// Useful to check if [AgoraCustomClient] is ready for further usage
  @override
  bool get isInitialized => _initialized;

  @override
  List<int> get users {
    final List<int> version =
        _sessionController.value.users.map((e) => e.uid).toList();

    return version;
  }

  @override
  SessionController get sessionController {
    return _sessionController;
  }

  @override
  RtcEngine get engine {
    return _sessionController.value.engine!;
  }

  static Future<String> platformVersion() async {
    final String version = await _channel.invokeMethod('getPlatformVersion');

    return version;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      await _sessionController.initializeEngine(
          agoraConnectionData: agoraConnectionData);
    } catch (e) {
      log('Error while initializing Agora RTC SDK: $e',
          level: Level.error.value);
    }

    if (agoraConnectionData.rtmEnabled) {
      try {
        await _sessionController.initializeRtm(
            agoraRtmClientEventHandler ?? const AgoraRtmClientEventHandler());
      } catch (e) {
        log('Error while initializing Agora RTM SDK. ${e.toString()}',
            level: Level.error.value);
      }
    }

    if (agoraChannelData?.clientRoleType ==
            ClientRoleType.clientRoleBroadcaster ||
        agoraChannelData?.clientRoleType == null) {
      if (callType == CallType.video) {
        await _sessionController.askForUserCameraAndMicPermission();
      } else {
        await _sessionController.askForUserMicPermission();
      }
    }
    if (enabledPermission != null) {
      await enabledPermission!.request();
    }

    _sessionController.createEvents(
      agoraRtmChannelEventHandler ?? const AgoraRtmChannelEventHandler(),
      agoraEventHandlers ?? const AgoraRtcEventHandlers(),
    );

    if (agoraChannelData != null) {
      _sessionController.setChannelProperties(agoraChannelData!);
    }
    await _sessionController.joinCallCustomChannel(callType);
    // if (callType == CallType.video) {
    //   await _sessionController.joinVideoCustomChannel();
    // } else {
    //   await _sessionController.joinVoiceCustomChannel();
    // }

    _initialized = true;
  }

  @override
  Future<void> release() async {
    _initialized = false;
    await endCall(sessionController: _sessionController);
  }
}

enum CallType { voice, video }
