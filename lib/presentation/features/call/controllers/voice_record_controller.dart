import 'dart:developer';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/all.dart';
import '../../../../repositories/all.dart';

class VoiceRecordController {
  final RtcEngine rtcEngine;
  bool startRecord = false;
  // late final RecorderController recorderController;
  String path = '';

  VoiceRecordController(this.rtcEngine);

  final callRepository = Get.find<CallRepository>();
  final chatRepository = Get.find<ChatRepository>();
  int currentToUserId = 0;
  final record = AudioRecorder();

  Future initialize() async {
    // recorderController = RecorderController()
    //   ..androidEncoder = AndroidEncoder.aac
    //   ..androidOutputFormat = AndroidOutputFormat.mpeg4
    //   ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
    //   ..sampleRate = 44100;
    rtcEngine.registerEventHandler(RtcEngineEventHandler(
      onAudioMixingFinished: () async {
        await rtcEngine.muteRemoteAudioStream(
          uid: currentToUserId,
          mute: false,
        );
      },
    ));
    Directory? storageDirectory;
    storageDirectory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    path = storageDirectory!.path;
  }

  Future<String> _getPath() async {
    return '$path/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  Future<void> startRecording() async {
    try {
      // final path = await _getPath();

      // await recorderController.record(path: path);
      if (await record.hasPermission()) {
        // Start recording to file
        log('11111111111111111111111');
        await record.start(const RecordConfig(encoder: AudioEncoder.wav),
            path: '$path/audio_${DateTime.now().millisecondsSinceEpoch}.wav');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> stopRecording(
      String roomId, int toUerId, String fromLang, String toLang) async {
    try {
      // recorderController.reset();
      // final pathAudio = await recorderController.stop(false);
      final pathAudio = await record.stop();
      log('11111111111$pathAudio');
      if (pathAudio != null) {
        final path =
            await callRepository.translateAudio(pathAudio, fromLang, toLang);
        await chatRepository.sendCallTranslate(
          roomId: roomId,
          data: path,
        );
      }
    } catch (e) {
      LogUtil.e(e, name: runtimeType.toString());
    }
    return;
  }

  Future<void> playAudio(String path, int toUerId) async {
    currentToUserId = toUerId;
    await rtcEngine.muteRemoteAudioStream(uid: toUerId, mute: true);
    await rtcEngine.startAudioMixing(
      filePath: path,
      loopback: false,
      cycle: 1,
    );
  }
}
