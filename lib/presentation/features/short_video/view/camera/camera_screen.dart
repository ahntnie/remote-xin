import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:bubbly_camera/bubbly_camera.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:get/get.dart';
import 'package:hl_image_picker/hl_image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';

import '../../../../../core/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../custom_view/common_ui.dart';
import '../../modal/sound/sound.dart';
import '../../utils/assert_image.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/url_res.dart';
import '../../view/dialog/confirmation_dialog.dart';
import '../../view/music/music_screen.dart';
import '../../view/preview_screen.dart';

class CameraScreen extends StatefulWidget {
  final String? soundUrl;
  final String? soundTitle;
  final String? soundId;

  const CameraScreen({super.key, this.soundUrl, this.soundTitle, this.soundId});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool isFlashOn = false;
  bool isFront = false;
  bool isSelected15s = true;
  bool isMusicSelect = false;
  bool isStartRecording = false;
  bool isRecordingStaring = false;
  bool isShowPlayer = false;
  String? soundId = '';

  bool isLoading = false;

  Timer? timer;
  double currentSecond = 0;
  double currentPercentage = 0;
  double totalSeconds = 15;

  AudioPlayer? _audioPlayer;

  SoundList? _selectedMusic;
  String? _localMusic;

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  String? _videoPath;

  // String selectMusic =
  //     'https://res.cloudinary.com/dxgbkcpvy/video/upload/v1734329789/iLoveYt_mp3cut.net_1_jvrxtf.mp3';

  Map<String, dynamic> creationParams = <String, dynamic>{};
  final FlutterVideoInfo _flutterVideoInfo = FlutterVideoInfo();
  final ReceivePort _port = ReceivePort();
  final _picker = HLImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.soundUrl != null) {
      soundId = widget.soundId;
      _bindBackgroundIsolate();
      FlutterDownloader.registerCallback(downloadCallback);
      downloadMusic();
    }
    if (Platform.isIOS) {
      _initCamera();
    }
    const MethodChannel(ConstRes.bubblyCamera)
        .setMethodCallHandler((payload) async {
      print('payload : $payload');
      replaceVideoAudio(videoPath: payload.arguments.toString());
      return;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer?.release();
    _audioPlayer?.dispose();
    _unbindBackgroundIsolate();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    log(_cameras.toString());
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.max);
      await _controller!.initialize();
      setState(() {});
    }
  }

  Future<void> _startVideoRecording() async {
    if (!_controller!.value.isInitialized) return;

    try {
      if (currentSecond == 0) {
        if (_selectedMusic != null) {
          _audioPlayer = AudioPlayer(playerId: '1');
          await _audioPlayer?.play(
            UrlSource(_selectedMusic!.sound ?? ''),
            mode: PlayerMode.mediaPlayer,
            ctx: const AudioContext(
              android: AudioContextAndroid(isSpeakerphoneOn: true),
              iOS: AudioContextIOS(
                category: AVAudioSessionCategory.playAndRecord,
                options: [
                  AVAudioSessionOptions.allowAirPlay,
                  AVAudioSessionOptions.allowBluetooth,
                  AVAudioSessionOptions.allowBluetoothA2DP,
                  AVAudioSessionOptions.defaultToSpeaker
                ],
              ),
            ),
          );
        }

        totalSeconds = 30;

        initProgress();
        await _controller!.startVideoRecording();
      }
    } catch (e) {
      ViewUtil.showToast(title: 'Error', message: e.toString());
    }
  }

  Future<void> _stopVideoRecording() async {
    // if (!_controller!.value.isRecording) return;

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      if (_audioPlayer != null) {
        _audioPlayer!.dispose();
      }
      setState(() {
        _isRecording = false;
        _videoPath = videoFile.path;
      });
      replaceVideoAudio(
        videoPath: videoFile.path,
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) {
      //     return PreviewScreen(
      //       postVideo: videoFile.path,
      //       thumbNail: '${Platform.pathSeparator}thumbNail.png',
      //       sound: '',
      //       duration: currentSecond.toInt(),
      //     );
      //   }),
      // );
    } catch (e) {
      ViewUtil.showToast(title: 'Error', message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Platform.isAndroid
              ? AndroidView(
                  viewType: 'camera',
                  layoutDirection: TextDirection.ltr,
                  creationParams: creationParams,
                  creationParamsCodec: const StandardMessageCodec(),
                )
              : _controller != null
                  ? Positioned.fill(child: CameraPreview(_controller!))
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: LinearProgressIndicator(
                        backgroundColor: ColorRes.white,
                        value: currentPercentage / 100,
                        color: ColorRes.colorPrimaryDark),
                  ),
                ),
              ),
              Visibility(
                visible: isMusicSelect,
                replacement: const SizedBox(height: 10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    widget.soundTitle != null
                        ? widget.soundTitle ?? ''
                        : _selectedMusic != null
                            ? _selectedMusic?.soundTitle ?? ''
                            : '',
                    style: const TextStyle(
                        fontFamily: FontRes.fNSfUiSemiBold,
                        fontSize: 15,
                        color: ColorRes.white),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isStartRecording
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: IconWithRoundGradient(
                            size: 22,
                            iconData: Icons.close_rounded,
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (mContext) {
                                    return ConfirmationDialog(
                                      aspectRatio: 2,
                                      title1: context.l10n.short__are_you_sure,
                                      title2: context
                                          .l10n.short__do_you_want_to_go_back,
                                      positiveText: context.l10n.short__yes,
                                      onPositiveTap: () async {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    );
                                  });
                            },
                          ),
                        ),
                  isStartRecording
                      ? const SizedBox()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.text2.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(100)),
                          child: Row(
                            children: [
                              const Image(
                                image: AssetImage(icMusic),
                                color: ColorRes.white,
                                height: 16,
                                width: 16,
                              ),
                              AppSpacing.gapW8,
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 0.5.sw),
                                child: Text(
                                  _selectedMusic != null
                                      ? _selectedMusic!.soundTitle ?? ''
                                      : 'Select Music',
                                  style: AppTextStyles.s16w700.text1Color,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ).clickable(() {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15))),
                            backgroundColor: ColorRes.colorPrimaryDark,
                            isScrollControlled: true,
                            builder: (context) {
                              return MusicScreen(
                                (data) async {
                                  // isMusicSelect = true;
                                  // _selectedMusic = data;
                                  // _localMusic = localMusic;
                                  // soundId = data?.soundId.toString();
                                  _selectedMusic = data;
                                  setState(() {});
                                },
                              );
                            },
                          ).then((value) {
                            Provider.of<MyLoading>(context, listen: false)
                                .setLastSelectSoundId('');
                          });
                        }),
                  const Spacer(),
                  Column(
                    children: [
                      AppSpacing.gapH12,
                      AppIcon(
                        icon: !isFlashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        size: 28,
                        onTap: () async {
                          isFlashOn = !isFlashOn;
                          setState(() {});
                          await BubblyCamera.flashOnOff;
                        },
                      ),
                      AppSpacing.gapH20,
                      isStartRecording
                          ? const SizedBox()
                          : AppIcon(
                              icon: Icons.flip_camera_android_rounded,
                              size: 28,
                              onTap: () async {
                                isFront = !isFront;
                                await BubblyCamera.toggleCamera;
                                setState(() {});
                              },
                            ),
                    ],
                  ).paddingOnly(right: 20)
                ],
              ),
              const Spacer(),
              // isRecordingStaring
              //     ? const SizedBox()
              //     : Visibility(
              //         visible: !isMusicSelect,
              //         child: Row(ƒ
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             SecondsTab(
              //               onTap: () {
              //                 isSelected15s = true;
              //                 totalSeconds = 15;
              //                 setState(() {});
              //               },
              //               isSelected: isSelected15s,
              //               title: AppRes.fiftySecond,
              //             ),
              //             const SizedBox(width: 15),
              //             SecondsTab(
              //               onTap: () {
              //                 isSelected15s = false;
              //                 totalSeconds = 30;
              //                 setState(() {});
              //               },
              //               isSelected: !isSelected15s,
              //               title: AppRes.thirtySecond,
              //             ),
              //           ],
              //         ),
              //       ),
              const SizedBox(height: 5),
              SafeArea(
                top: false,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isRecordingStaring
                          ? SizedBox(
                              width: 40,
                              height: isMusicSelect ? 0 : 40,
                            )
                          : Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.text2.withOpacity(0.4)),
                              child: AppIcon(
                                icon: Icons.image,
                                size: 28,
                                onTap: () => _showFilePicker(),
                              ),
                            ),
                      InkWell(
                        onTap: () async {
                          if (Platform.isIOS) {
                            isStartRecording
                                ? _stopVideoRecording()
                                : _startVideoRecording();
                            isStartRecording = !isStartRecording;
                            isRecordingStaring = true;
                            setState(() {});
                          } else {
                            isStartRecording = !isStartRecording;
                            isRecordingStaring = true;
                            setState(() {});
                            startProgress();
                          }
                        },
                        child: Container(
                          height: 85,
                          width: 85,
                          decoration: const BoxDecoration(
                              color: ColorRes.white, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(10.0),
                          alignment: Alignment.center,
                          child: isStartRecording
                              ? const Icon(
                                  Icons.pause,
                                  color: AppColors.negative2,
                                  size: 50,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.negative2,
                                    shape: isStartRecording
                                        ? BoxShape.rectangle
                                        : BoxShape.circle,
                                  ),
                                ),
                        ),
                      ),
                      Platform.isIOS
                          ? const SizedBox()
                          : !isStartRecording
                              ? Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.text2.withOpacity(0.4)),
                                  child: AppIcon(
                                    icon: Icons.check_circle_rounded,
                                    size: 28,
                                    onTap: () async {
                                      if (Platform.isIOS) {
                                      } else {
                                        await BubblyCamera.stopRecording;
                                      }
                                    },
                                  ),
                                )
                              : AppSpacing.gapW40,
                    ],
                  ),
                ),
              ),
            ],
          ),
          isLoading
              ? Positioned.fill(
                  child: Container(
                  width: 1.sw,
                  height: 1.sh,
                  color: Colors.black.withOpacity(0.1),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.blue10,
                            ),
                          ),
                          AppSpacing.gapH8,
                          Text(
                            context.l10n.short__procesing,
                            style: AppTextStyles.s14w600.text2Color,
                          )
                        ],
                      ),
                    ),
                  ),
                ))
              : const SizedBox()
        ],
      ),
    );
  }

  Future<File> downloadFile(String url,
      {required Function(double) onProgressChanged}) async {
    try {
      // Get temporary directory
      final dir = await getTemporaryDirectory();
      final fileName =
          'downloaded_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final filePath = '${dir.path}/$fileName';

      // Initialize Dio for download
      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (receivedBytes, totalBytes) {
          // Calculate and report download progress
          final double progress = receivedBytes / totalBytes;
          onProgressChanged(progress);
        },
      );

      return File(filePath);
    } catch (e) {
      throw Exception('Download failed: ${e.toString()}');
    }
  }

  Future<void> replaceVideoAudio({required String videoPath}) async {
    try {
      if (_selectedMusic != null) {
        setState(() {
          isLoading = true;
        });
        final MediaInfo videoInfo = await VideoCompress.getMediaInfo(videoPath);
        final int videoDuration = (videoInfo.duration ?? 0).toInt();
        // 2. Download audio file
        final audioFile = await downloadFile(_selectedMusic!.sound ?? '',
            onProgressChanged: (progress) {
          log(progress.toString());
        });

        // 3. Lấy thư mục tạm
        final Directory tempDir = await getTemporaryDirectory();
        final String outputPath =
            '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}replaced_audio_video.mp4';
        final String trimmedAudioPath =
            '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}trimmed_audio.mp4';

        // 4. Cắt audio bằng với duration video
        final String ffmpegTrimCommand =
            '-i "${audioFile.path}" -t ${videoDuration / 1000} "$trimmedAudioPath"';

        await FFmpegKit.execute(ffmpegTrimCommand);

        // // 5. Thay thế âm thanh trong video
        final String ffmpegReplaceCommand =
            '-i "$videoPath" -i "$trimmedAudioPath" -map 0:v -map 1:a -c:v copy -c:a aac "$outputPath"';

        await FFmpegKit.execute(ffmpegReplaceCommand).then((session) async {
          // final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
          //   outputPath,
          //   quality:
          //       VideoQuality.Res1280x720Quality, // Chọn mức chất lượng phù hợp
          // );
          final thumbnail = await VideoCompress.getFileThumbnail(outputPath);
          // if (mediaInfo != null) {
          setState(() {
            isLoading = true;
          });
          Navigator.pop(context);
          // Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return PreviewScreen(
                soundId: _selectedMusic!.soundId ?? 0,
                postVideo: outputPath,
                thumbNail: thumbnail.path,
                sound: '',
                duration: videoDuration ~/ 1000,
              );
            }),
          );
          // }
        });
      } else {
        setState(() {
          isLoading = true;
        });
        // final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        //   videoPath,
        //   quality:
        //       VideoQuality.Res640x480Quality, // Chọn mức chất lượng phù hợp
        // );
        final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
        setState(() {
          isLoading = false;
        });
        // if (mediaInfo != null) {
        Navigator.pop(context);
        // Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return PreviewScreen(
              postVideo: videoPath,
              thumbNail: thumbnail.path,
              sound: '',
              duration: 30,
              soundId: 1,
            );
          }),
        );
        // }
      }
    } catch (e) {
      ViewUtil.showToast(title: 'Error', message: e.toString());
    }
  }

  //   Future<String?> compressVideo({
  //   required String inputPath,
  //   int targetSizeMB = 8,
  //   int height = 1280,    // 720p height for 9:16 ratio
  //   int width = 720,      // 720p width for 9:16 ratio
  //   int bitrate = 1500,   // 1.5 Mbps
  //   int fps = 30,
  //   void Function(double)? onProgress,
  // }) async {
  //   try {
  //     final Directory tempDir = await getTemporaryDirectory();
  //     final String outputPath = path.join(
  //       tempDir.path,
  //       'compressed_${DateTime.now().millisecondsSinceEpoch}.mp4',
  //     );

  //     // FFmpeg command cho video mobile tối ưu
  //     final String command = '''
  //       -i $inputPath
  //       -c:v libx264
  //       -preset slower
  //       -crf 23
  //       -vf scale=$width:$height
  //       -r $fps
  //       -b:v ${bitrate}k
  //       -maxrate ${bitrate * 1.5}k
  //       -bufsize ${bitrate * 3}k
  //       -c:a aac
  //       -b:a 128k
  //       -movflags +faststart
  //       -y $outputPath
  //     ''';

  //     // Thực thi FFmpeg với progress tracking
  //     final session = await FFmpegKit.execute(command);
  //     final returnCode = await session.getReturnCode();

  //     // Check if the execution was successful
  //     if (ReturnCode.isSuccess(returnCode)) {
  //       final duration = await getVideoDuration(inputPath);

  //       // Listen to progress updates
  //       await session.getOutput().then((output) {
  //         if (output != null && onProgress != null && duration > 0) {
  //           final time = _parseTimeFromOutput(output);
  //           final progress = (time / duration) * 100;
  //           onProgress(progress.clamp(0.0, 100.0));
  //         }
  //       });

  //       return outputPath;
  //     } else {
  //       final logs = await session.getLogs();
  //       throw Exception('Error compressing video: ${logs.join('\n')}');
  //     }
  //   } catch (e) {
  //     print('Error in video compression: $e');
  //     return null;
  //   }
  // }

  //   double _parseTimeFromOutput(String output) {
  //   final timeMatch = RegExp(r'time=(\d{2}):(\d{2}):(\d{2})\.(\d{2})')
  //       .firstMatch(output);

  //   if (timeMatch != null) {
  //     final hours = int.parse(timeMatch.group(1)!);
  //     final minutes = int.parse(timeMatch.group(2)!);
  //     final seconds = int.parse(timeMatch.group(3)!);

  //     return (hours * 3600) + (minutes * 60) + seconds.toDouble();
  //   }
  //   return 0.0;
  // }

  // // Kiểm tra kích thước file
  // Future<double> getVideoSize(String path) async {
  //   final File file = File(path);
  //   final int bytes = await file.length();
  //   return bytes / (1024 * 1024); // Convert to MB
  // }

  //  Future<double> getVideoDuration(String videoPath) async {
  //   try {
  //     final session = await FFmpegKit.execute(
  //       '-i $videoPath -f null -'
  //     );

  //     final output = await session.getOutput();
  //     if (output != null) {
  //       final durationMatch = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})')
  //           .firstMatch(output);

  //       if (durationMatch != null) {
  //         final hours = int.parse(durationMatch.group(1)!);
  //         final minutes = int.parse(durationMatch.group(2)!);
  //         final seconds = int.parse(durationMatch.group(3)!);

  //         return (hours * 3600) + (minutes * 60) + seconds.toDouble();
  //       }
  //     }
  //     return 0.0;
  //   } catch (e) {
  //     print('Error getting video duration: $e');
  //     return 0.0;
  //   }
  // }

  void _bindBackgroundIsolate() {
    final bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      final int status = data[1];

      if (status == 3) {
        Navigator.pop(context);
        _audioPlayer = AudioPlayer();
        isMusicSelect = true;
        _localMusic = '${_localMusic!}/${widget.soundUrl!}';
        setState(() {});
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  Future<void> downloadMusic() async {
    _localMusic =
        (await _findLocalPath()) + Platform.pathSeparator + UrlRes.camera;
    final savedDir = Directory(_localMusic!);
    final bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    if (File(_localMusic! + widget.soundUrl!).existsSync()) {
      File(_localMusic! + widget.soundUrl!).deleteSync();
    }
    await FlutterDownloader.enqueue(
      url: ConstRes.itemBaseUrl + widget.soundUrl!,
      savedDir: _localMusic!,
      showNotification: false,
      openFileFromNotification: false,
    );
    CommonUI.showLoader(context);
  }

  // Recording
  Future<void> startProgress() async {
    if (timer == null) {
      initProgress();
    } else {
      if (isStartRecording) {
        initProgress();
      } else {
        cancelTimer();
      }
    }
    if (isStartRecording) {
      if (currentSecond == 0) {
        if (_selectedMusic != null) {
          _audioPlayer = AudioPlayer(playerId: '1');
          await _audioPlayer?.play(
            UrlSource(_selectedMusic!.sound ?? ''),
            mode: PlayerMode.mediaPlayer,
            ctx: const AudioContext(
              android: AudioContextAndroid(isSpeakerphoneOn: true),
              iOS: AudioContextIOS(
                category: AVAudioSessionCategory.playAndRecord,
                options: [
                  AVAudioSessionOptions.allowAirPlay,
                  AVAudioSessionOptions.allowBluetooth,
                  AVAudioSessionOptions.allowBluetoothA2DP,
                  AVAudioSessionOptions.defaultToSpeaker
                ],
              ),
            ),
          );
        }

        totalSeconds = 30;
        initProgress();

        await BubblyCamera.startRecording;
      } else {
        print('Audio Resume Recording');
        await _audioPlayer?.resume();
        await BubblyCamera.resumeRecording;
      }
    } else {
      print('Audio Pause Recording');
      await _audioPlayer?.pause();
      await BubblyCamera.pauseRecording;
    }
    print('============ $currentSecond');
  }

  // Stop Merge For iOS
  Future<void> _stopAndMergeVideoForIos({bool isAutoStop = false}) async {
    print('_stopAndMergeVideoForIos');
    CommonUI.showLoader(context);
    if (isAutoStop) {
      await BubblyCamera.pauseRecording;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    await BubblyCamera.mergeAudioVideo(_localMusic ?? '');
  }

  Future<void> gotoPreviewScreen(String pathOfVideo) async {
    if (soundId != null && soundId!.isNotEmpty) {
      CommonUI.showLoader(context);
      final String f = await _findLocalPath();
      if (!Platform.isAndroid) {
        FFmpegKit.execute(
                '-i $pathOfVideo -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
            .then(
          (returnCode) async {
            Navigator.pop(context);
            // Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewScreen(
                  postVideo: pathOfVideo,
                  thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                  soundId: 1,
                  duration: currentSecond.toInt(),
                ),
              ),
            );
          },
        );
      } else {
        if (Platform.isAndroid && isFront) {
          await FFmpegKit.execute(
              '-i "$pathOfVideo" -y -vf hflip "$f${Platform.pathSeparator}out1.mp4"');
          FFmpegKit.execute(
                  "-i \"$f${Platform.pathSeparator}out1.mp4\" -i $_localMusic -y -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest $f${Platform.pathSeparator}out.mp4")
              .then((returnCode) {
            FFmpegKit.execute(
                    '-i $f${Platform.pathSeparator}out.mp4 -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
                .then(
              (returnCode) async {
                Navigator.pop(context);
                // Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreen(
                      postVideo: '$f${Platform.pathSeparator}out.mp4',
                      thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                      soundId: 1,
                      duration: currentSecond.toInt(),
                    ),
                  ),
                );
              },
            );
          });
        } else {
          FFmpegKit.execute(
                  "-i $pathOfVideo -i $_localMusic -y -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest $f${Platform.pathSeparator}out.mp4")
              .then((returnCode) {
            FFmpegKit.execute(
                    '-i $f${Platform.pathSeparator}out.mp4 -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
                .then(
              (returnCode) async {
                Navigator.pop(context);
                // Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreen(
                      postVideo: '$f${Platform.pathSeparator}out.mp4',
                      thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                      soundId: 1,
                      duration: currentSecond.toInt(),
                    ),
                  ),
                );
              },
            );
          });
        }
      }
      return;
    }
    CommonUI.showLoader(context);
    final String f = await _findLocalPath();
    final String soundPath =
        '$f${Platform.pathSeparator + DateTime.now().millisecondsSinceEpoch.toString()}sound.wav';
    await FFmpegKit.execute('-i "$pathOfVideo" -y $soundPath');
    if (Platform.isAndroid && isFront) {
      await FFmpegKit.execute(
          '-i "$pathOfVideo" -y -vf hflip "$f${Platform.pathSeparator}out1.mp4"');
      FFmpegKit.execute(
              '-i "$f${Platform.pathSeparator}out1.mp4" -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
          .then(
        (returnCode) async {
          Navigator.pop(context);
          Navigator.pop(context);
          print(' 🛑 Recording Video 🛑');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewScreen(
                postVideo: '$f${Platform.pathSeparator}out1.mp4',
                thumbNail: '$f${Platform.pathSeparator}thumbNail.png',
                sound: soundPath,
                duration: currentSecond.toInt(),
              ),
            ),
          );
        },
      );
    } else {
      FFmpegKit.execute(
              '-i "$pathOfVideo" -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
          .then(
        (returnCode) async {
          print('Recording Video without Sound 🛑 ');
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return PreviewScreen(
                postVideo: pathOfVideo,
                thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                sound: soundPath,
                duration: currentSecond.toInt(),
              );
            }),
          );
        },
      );
    }
  }

  Future<void> _showFilePicker() async {
    HapticFeedback.mediumImpact();
    CommonUI.showLoader(context);
    await _picker
        .openPicker(
      pickerOptions: const HLPickerOptions(
        mediaType: MediaType.video,
        compressQuality: 0.1,
        maxDuration: 60,
      ),
    )
        .then(
      (value) async {
        Navigator.pop(context);
        if (value.isNotEmpty && value.first.path.isNotEmpty) {
          final VideoData? a =
              await _flutterVideoInfo.getVideoInfo(value.first.path);
          if (a!.filesize! / 1000000 > 40) {
            await showDialog(
              context: context,
              builder: (mContext) => ConfirmationDialog(
                aspectRatio: 1.8,
                title1: context.l10n.short__too_large_video,
                title2: context.l10n.short__this_video_greater_than_40mb,
                positiveText: context.l10n.short__select_another,
                onPositiveTap: () {
                  _showFilePicker();

                  Navigator.pop(context);
                },
              ),
            );
            return;
          }
          if ((a.duration! / 1000) > 180) {
            await showDialog(
                context: context,
                builder: (mContext) {
                  return ConfirmationDialog(
                    aspectRatio: 1.8,
                    title1: context.l10n.short__too_long_video,
                    title2: context.l10n.short__this_video_greater_than_3min,
                    positiveText: context.l10n.short__select_another,
                    onPositiveTap: () {
                      Navigator.pop(context);
                      _showFilePicker();
                    },
                  );
                });
            return;
          }
          CommonUI.showLoader(context);
          final String f = await _findLocalPath();
          await FFmpegKit.execute(
              '-i "${value.first.path}" -y $f${Platform.pathSeparator}sound.wav');
          FFmpegKit.execute(
                  '-i "${value.first.path}" -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
              .then(
            (returnCode) async {
              Navigator.pop(context);
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PreviewScreen(
                    postVideo: value.first.path,
                    thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                    sound: "$f${Platform.pathSeparator}sound.wav",
                    duration: (a.duration ?? 0) ~/ 1000,
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  void initProgress() {
    timer?.cancel();
    timer = null;

    timer = Timer.periodic(const Duration(milliseconds: 10), (time) async {
      currentSecond += 0.01;
      currentPercentage = (100 * currentSecond) / totalSeconds;
      log('time: $currentSecond');
      log('time: $totalSeconds');
      if (totalSeconds < currentSecond) {
        timer?.cancel();
        timer = null;
        if (_audioPlayer != null) {
          _audioPlayer!.pause();
        }

        if (Platform.isIOS) {
          _stopVideoRecording();
        } else {
          await BubblyCamera.stopRecording;
        }
      }
      setState(() {});
    });
  }

  void cancelTimer() {
    timer?.cancel();
    timer = null;
  }
}

class IconWithRoundGradient extends StatelessWidget {
  final IconData iconData;
  final double size;
  final Function? onTap;

  const IconWithRoundGradient(
      {required this.iconData, required this.size, super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: InkWell(
        onTap: () => onTap?.call(),
        child: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(color: AppColors.text2.withOpacity(0.4)),
          child: Icon(iconData, color: ColorRes.white, size: size),
        ),
      ),
    );
  }
}

class ImageWithRoundGradient extends StatelessWidget {
  final String imageData;
  final double padding;

  const ImageWithRoundGradient(this.imageData, this.padding, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(color: AppColors.text2.withOpacity(0.4)),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Image(
            image: AssetImage(imageData),
            color: ColorRes.white,
          ),
        ),
      ),
    );
  }
}
