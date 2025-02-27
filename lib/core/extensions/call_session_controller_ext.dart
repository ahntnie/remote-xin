import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit/controllers/rtc_token_handler.dart';
import 'package:agora_uikit/controllers/rtm_token_handler.dart';
import 'package:agora_uikit/controllers/session_controller.dart';

import '../../presentation/features/call/call.dart';
import '../utils/agora_voice_client.dart';

extension CallSessionController on SessionController {
  /// Function to join the video,voice call.
  Future<void> joinCallCustomChannel(CallType callType) async {
    if (value.layoutType == Layout.oneToOne && value.users.length == 1) return;

    // [generatedRtmId] is the unique ID for a user generated using the timestamp in milliseconds.
    value = value.copyWith(
      generatedRtmId: value.connectionData!.rtmUid ??
          DateTime.now().millisecondsSinceEpoch.toString(),
    );
    // await value.engine?.setParameters("{\"rtc.using_ui_kit\": 1}");
    if (callType == CallType.video) {
      await value.engine?.enableVideo();
      await value.engine?.enableAudioVolumeIndication(
        interval: 200,
        smooth: 3,
        reportVad: true,
      );
      value = value.copyWith(
        isLocalVideoDisabled: false,
        showLocalCameraview: true,
      );
      addDataToUserdata({
        'speakerType': 'external',
        'callType': 'video',
      });
    }
    if (callType == CallType.voice) {
      value = value.copyWith(
        isLocalVideoDisabled: true,
        showLocalCameraview: false,
      );
      addDataToUserdata({
        'speakerType': 'internal',
        'callType': 'voice',
      });
      await value.engine?.disableVideo();
      //to set internal speaker(loa trong)
      await value.engine?.setDefaultAudioRouteToSpeakerphone(false);
      // await value.engine?.muteLocalVideoStream(true);
    }

    if (value.connectionData?.tokenUrl != null) {
      await getToken(
        tokenUrl: value.connectionData!.tokenUrl,
        channelName: value.connectionData!.channelName,
        uid: value.connectionData!.uid,
        sessionController: this,
      );
      if (value.connectionData!.rtmEnabled) {
        await getRtmToken(
          tokenUrl: value.connectionData!.tokenUrl,
          sessionController: this,
        );
      }
    }
    if (callType == CallType.video) {
      await value.engine?.startPreview();
    }
    await value.engine?.joinChannel(
      token: value.connectionData?.tempToken ?? value.generatedToken ?? '',
      channelId: value.connectionData!.channelName,
      uid: value.connectionData!.uid!,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> askForUserMicPermission() async {
    await [Permission.microphone].request();
  }

  bool isSpeakerDisabled() {
    return value.userdata?['speakerMute'] == true;
  }

  Future enableSpeaker() async {
    await value.engine?.muteAllRemoteAudioStreams(false);
    addDataToUserdata({'speakerMute': false});
  }

  Future disableSpeaker() async {
    await value.engine?.muteAllRemoteAudioStreams(true);
    addDataToUserdata({'speakerMute': true});
  }

  bool isInternalSpeaker() {
    return value.userdata?['speakerType'] == 'internal';
  }

  bool isExternalSpeaker() {
    return value.userdata?['speakerType'] == 'external';
  }

  Future enableExternalSpeaker() async {
    await value.engine?.setEnableSpeakerphone(true);
    addDataToUserdata({'speakerType': 'external'});
  }

  Future enableInternalSpeaker() async {
    await value.engine?.setEnableSpeakerphone(false);
    addDataToUserdata({'speakerType': 'internal'});
  }

  Future callVideo() async {
    addDataToUserdata({'callType': 'video'});
    await CallKitManager.instance.turnOnKeepScreenOn();
  }

  Future callVoice() async {
    addDataToUserdata({'callType': 'voice'});
    await CallKitManager.instance.turnOffKeepScreenOn();
  }

  bool isCallVoice() {
    return value.userdata?['callType'] == 'voice';
  }

  bool isCallVideo() {
    return value.userdata?['callType'] == 'video';
  }

  void addDataToUserdata(Map<String, dynamic> data) {
    if (value.userdata == null) {
      value = value.copyWith(userdata: data);
    } else {
      value.userdata!.addAll(data);
      value = value.copyWith(userdata: value.userdata);
    }
  }
}
