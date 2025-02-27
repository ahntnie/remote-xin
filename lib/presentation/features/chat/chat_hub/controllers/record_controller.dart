import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../models/all.dart';
import 'chat_hub_controller.dart';

class RecordController extends GetxController {
  late final RecorderController recorderController;
  final PlayerController playController = PlayerController();

  RxString path = ''.obs;
  RxBool isRecording = false.obs;
  RxBool isRecordingCompleted = false.obs;
  RxBool isPlaying = false.obs;
  RxString maxDuration = ''.obs;

  final StreamController<Duration> _currentDurationController =
      StreamController.broadcast();

  Stream<Duration> get onPlayingCurrentDurationChanged =>
      _currentDurationController.stream;

  @override
  Future<void> onInit() async {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;

    path.value = await _getPath();

    playController.onCurrentDurationChanged.listen((milliseconds) {
      _currentDurationController.add(Duration(milliseconds: milliseconds));
    });

    super.onInit();
  }

  @override
  Future<void> onClose() async {
    recorderController.dispose();
    playController.dispose();
    if (File(path.value).existsSync()) {
      await File(path.value).delete();
    }
    super.onClose();
  }

  Future<String> _getPath() async {
    final dir = await getApplicationDocumentsDirectory();

    return '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  Future<void> startRecording() async {
    try {
      path.value = await _getPath();
      isRecording.value = true;
      update();

      await recorderController.record(path: path.value);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> stopRecording() async {
    recorderController.reset();

    final pathAudio = await recorderController.stop(false);

    if (pathAudio != null) {
      isRecordingCompleted.value = true;

      final Duration max = recorderController.recordedDuration;
      maxDuration.value = max.inMilliseconds.toString();
      _currentDurationController.add(max);
      path.value = pathAudio;
      update();

      log(pathAudio);
      log('Recorded file size: ${File(pathAudio).lengthSync()}');
    }

    return;
  }

  Future<void> deleteRecord() async {
    await stopRecording();

    if (File(path.value).existsSync()) {
      await File(path.value).delete();
    }

    isRecording.value = false;
    isRecordingCompleted.value = false;
    update();
  }

  Future<void> playAudio() async {
    await playController.preparePlayer(
      path: path.value,
    );
    await playController.startPlayer();
    isPlaying.value = true;

    update();
  }

  Future<void> pauseAudio() async {
    await playController.pausePlayer();

    isPlaying.value = false;
    update();
  }

  Future<void> onSendAudio() async {
    if (!isRecordingCompleted.value) {
      recorderController.reset();

      final pathAudio = await recorderController.stop(false);
      if (pathAudio != null) {
        path.value = pathAudio;
      }
    }

    recorderController.reset();
    isRecording.value = false;
    isRecordingCompleted.value = false;
    update();

    if (File(path.value).existsSync()) {
      Get.find<ChatHubController>().sendMediaMessage(
        file: File(path.value),
        type: MessageType.audio,
      );
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
