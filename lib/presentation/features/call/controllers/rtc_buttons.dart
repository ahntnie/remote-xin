import 'dart:async';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit/controllers/session_controller.dart';

import '../../../../core/extensions/call_session_controller_ext.dart';

/// Function to mute/unmute the microphone
Future<void> toggleMute({required SessionController sessionController}) async {
  final status = await Permission.microphone.status;
  if (sessionController.value.isLocalUserMuted && status.isDenied) {
    await Permission.microphone.request();
  }
  sessionController.value = sessionController.value
      .copyWith(isLocalUserMuted: !sessionController.value.isLocalUserMuted);
  await sessionController.value.engine
      ?.muteLocalAudioStream(sessionController.value.isLocalUserMuted);
}

/// Function to mute/unmute the speaker
Future<void> toggleSpeaker({
  required SessionController sessionController,
}) async {
  if (sessionController.isInternalSpeaker()) {
    await sessionController.enableExternalSpeaker();

    return;
  }
  if (sessionController.isExternalSpeaker()) {
    await sessionController.enableInternalSpeaker();

    return;
  }
}

/// Function to toggle enable/disable the camera
Future<void> toggleCamera({
  required SessionController sessionController,
}) async {
  final status = await Permission.camera.status;
  var isVideoDisabled = sessionController.value.isLocalVideoDisabled;

  if (isVideoDisabled && status.isDenied) {
    await Permission.camera.request();
  }

  isVideoDisabled = !isVideoDisabled;

  if (isVideoDisabled) {
    await sessionController.value.engine?.muteLocalVideoStream(true);
    await sessionController.value.engine?.enableLocalVideo(false);
    await sessionController.callVoice();
    sessionController.value = sessionController.value.copyWith(
      showLocalCameraview: false,
      isLocalVideoDisabled: isVideoDisabled,
    );
  } else {
    await sessionController.value.engine?.enableLocalVideo(true);
    await sessionController.value.engine?.muteLocalVideoStream(false);
    await sessionController.value.engine?.enableVideo();
    // await sessionController.enableExternalSpeaker();
    await sessionController.callVideo();
    sessionController.value = sessionController.value.copyWith(
      showLocalCameraview: true,
      isLocalVideoDisabled: isVideoDisabled,
    );
  }
}

/// Function to switch between front and rear camera
Future<void> switchCamera(
    {required SessionController sessionController}) async {
  final status = await Permission.camera.status;
  if (status.isDenied) {
    await Permission.camera.request();
  }
  await sessionController.value.engine?.switchCamera();
}

/// Function to dispose the RTC and RTM engine.
Future<void> endCall({required SessionController sessionController}) async {
  if (sessionController.value.connectionData!.screenSharingEnabled &&
      sessionController.value.isScreenShared) {
    await sessionController.value.engine?.stopScreenCapture();
  }
  await sessionController.value.engine?.stopPreview();
  await sessionController.value.engine?.leaveChannel();
  if (sessionController.value.connectionData!.rtmEnabled) {
    await sessionController.value.agoraRtmChannel?.leave();
    await sessionController.value.agoraRtmClient?.logout();
  }
  await sessionController.value.engine?.release();
}

Timer? timer;

/// Function to auto hide the button class.
Future<void> toggleVisible({
  required SessionController sessionController,
  int autoHideButtonTime = 5,
  bool? visible,
}) async {
  if (visible != null) {
    sessionController.value =
        sessionController.value.copyWith(visible: visible);

    return;
  }
  if (!sessionController.value.visible) {
    sessionController.value = sessionController.value
        .copyWith(visible: !sessionController.value.visible);
    timer = Timer(Duration(seconds: autoHideButtonTime), () {
      if (!sessionController.value.visible) return;
      sessionController.value = sessionController.value
          .copyWith(visible: !sessionController.value.visible);
    });
  } else {
    timer?.cancel();
    sessionController.value = sessionController.value
        .copyWith(visible: !sessionController.value.visible);
  }
}

void chat({required SessionController sessionController}) {}
