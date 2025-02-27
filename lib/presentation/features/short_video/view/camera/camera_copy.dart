// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:ui';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:bubbly_camera/bubbly_camera.dart';
// import 'package:camera/camera.dart';
// import 'package:dio/dio.dart';
// import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:flutter_video_info/flutter_video_info.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:just_audio/just_audio.dart' as prefix;
// import 'package:path_provider/path_provider.dart';

// import '../../../../resource/styles/app_colors.dart';
// import '../../custom_view/common_ui.dart';
// import '../../languages/languages_keys.dart';
// import '../../modal/sound/sound.dart';
// import '../../utils/app_res.dart';
// import '../../utils/assert_image.dart';
// import '../../utils/colors.dart';
// import '../../utils/const_res.dart';
// import '../../utils/font_res.dart';
// import '../../utils/url_res.dart';
// import '../dialog/confirmation_dialog.dart';
// import '../music/music_screen.dart';
// import '../preview_screen.dart';
// import 'widget/seconds_tab.dart';

// class CameraScreen extends StatefulWidget {
//   final String? soundUrl;
//   final String? soundTitle;
//   final String? soundId;

//   const CameraScreen({super.key, this.soundUrl, this.soundTitle, this.soundId});

//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   bool isFlashOn = false;
//   bool isFront = false;
//   bool isSelected15s = true;
//   bool isMusicSelect = false;
//   bool isStartRecording = false;
//   bool isRecordingStaring = false;
//   bool isShowPlayer = false;
//   String? soundId = '';

//   Timer? timer;
//   double currentSecond = 0;
//   double currentPercentage = 0;
//   double totalSeconds = 15;

//   AudioPlayer? _audioPlayer;

//   SoundList? _selectedMusic;
//   String? _localMusic;

//   Map<String, dynamic> creationParams = <String, dynamic>{};
//   final FlutterVideoInfo _flutterVideoInfo = FlutterVideoInfo();
//   final ReceivePort _port = ReceivePort();
//   final ImagePicker _picker = ImagePicker();

//   CameraController? _controller;
//   List<CameraDescription>? _cameras;
//   bool _isRecording = false;
//   String? _videoPath;

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//     // if (widget.soundUrl != null) {
//     //   soundId = widget.soundId;
//     //   _bindBackgroundIsolate();
//     //   FlutterDownloader.registerCallback(downloadCallback);
//     //   downloadMusic();
//     // }
//     const MethodChannel(ConstRes.bubblyCamera)
//         .setMethodCallHandler((payload) async {
//       print('payload : ${payload.arguments.toString()}');
//       gotoPreviewScreen(payload.arguments.toString());
//       // replaceVideoAudio(
//       //     videoPath: payload.arguments.toString(),
//       //     onlineAudioUrl:
//       //         'https://res.cloudinary.com/dxgbkcpvy/video/upload/v1734264731/iLoveYt_mp3cut.net_clrtwu.mp3');
//       return;
//     });
//   }

//   Future<void> _initCamera() async {
//     _cameras = await availableCameras();
//     log(_cameras.toString());
//     if (_cameras!.isNotEmpty) {
//       _controller = CameraController(_cameras![0], ResolutionPreset.max);
//       await _controller!.initialize();
//       setState(() {});
//     }
//   }

//   Future<void> _startVideoRecording() async {
//     if (!_controller!.value.isInitialized) return;

//     try {
//       await _controller!.startVideoRecording();
//       setState(() {
//         _isRecording = true;
//       });
//     } catch (e) {
//       print('Lỗi khi bắt đầu quay video: $e');
//     }
//   }

//   Future<void> _stopVideoRecording() async {
//     // if (!_controller!.value.isRecording) return;

//     try {
//       final XFile videoFile = await _controller!.stopVideoRecording();
//       setState(() {
//         _isRecording = false;
//         _videoPath = videoFile.path;
//       });
//       replaceVideoAudio(
//           videoPath: videoFile.path,
//           onlineAudioUrl:
//               'https://res.cloudinary.com/dxgbkcpvy/video/upload/v1734264731/iLoveYt_mp3cut.net_clrtwu.mp3');
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(builder: (context) {
//       //     return PreviewScreen(
//       //       postVideo: videoFile.path,
//       //       thumbNail: '${Platform.pathSeparator}thumbNail.png',
//       //       sound: '',
//       //       duration: currentSecond.toInt(),
//       //     );
//       //   }),
//       // );
//     } catch (e) {
//       print('Lỗi khi dừng quay video: $e');
//     }
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     _audioPlayer?.release();
//     _audioPlayer?.dispose();
//     _unbindBackgroundIsolate();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // return Container(
//     //   child: Center(
//     //     child: ElevatedButton(
//     //         onPressed: () {
//     //           replaceVideoAudio(
//     //               videoPath: '',
//     //               onlineAudioUrl:
//     //                   'https://res.cloudinary.com/dxgbkcpvy/video/upload/v1734264731/iLoveYt_mp3cut.net_clrtwu.mp3');
//     //         },
//     //         child: const Text('')),
//     //   ),
//     // );
//     // return _controller != null && _controller!.value.isInitialized
//     //     ? Stack(
//     //         children: [
//     //           Positioned.fill(child: CameraPreview(_controller!)),
//     //           Center(
//     //             child: ElevatedButton(
//     //               onPressed:
//     //                   _isRecording ? _stopVideoRecording : _startVideoRecording,
//     //               child: Text(_isRecording ? 'Dừng quay' : 'Bắt đầu quay'),
//     //             ),
//     //           ),
//     //         ],
//     //       )
//     //     : Container(
//     //         child: const Center(
//     //           child: CircularProgressIndicator(),
//     //         ),
//     //       );

//     return Scaffold(
//       //   body:
//       // resizeToAvoidBottomInset: true,
//       body: Stack(
//         children: [
//           // _controller != null && _controller!.value.isInitialized
//           //     ? CameraPreview(_controller!)
//           //     : const CircularProgressIndicator(),
//           Platform.isAndroid
//               ? AndroidView(
//                   viewType: 'camera',
//                   layoutDirection: TextDirection.ltr,
//                   creationParams: creationParams,
//                   creationParamsCodec: const StandardMessageCodec(),
//                 )
//               : UiKitView(
//                   viewType: 'camera',
//                   layoutDirection: TextDirection.ltr,
//                   creationParams: creationParams,
//                   creationParamsCodec: const StandardMessageCodec(),
//                 ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 10),
//               SafeArea(
//                 bottom: false,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.all(Radius.circular(10)),
//                     child: LinearProgressIndicator(
//                         backgroundColor: ColorRes.white,
//                         value: currentPercentage / 100,
//                         color: ColorRes.colorPrimaryDark),
//                   ),
//                 ),
//               ),
//               Visibility(
//                 visible: isMusicSelect,
//                 replacement: const SizedBox(height: 10),
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   child: Text(
//                     widget.soundTitle != null
//                         ? widget.soundTitle ?? ''
//                         : _selectedMusic != null
//                             ? _selectedMusic?.soundTitle ?? ''
//                             : '',
//                     style: const TextStyle(
//                         fontFamily: FontRes.fNSfUiSemiBold,
//                         fontSize: 15,
//                         color: ColorRes.white),
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   isStartRecording
//                       ? const SizedBox()
//                       : Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: IconWithRoundGradient(
//                             size: 22,
//                             iconData: Icons.close_rounded,
//                             onTap: () {
//                               showDialog(
//                                   context: context,
//                                   builder: (mContext) {
//                                     return ConfirmationDialog(
//                                       aspectRatio: 2,
//                                       title1: LKey.areYouSure.tr,
//                                       title2: LKey.doYouReallyWantToGoBack.tr,
//                                       positiveText: LKey.yes.tr,
//                                       onPositiveTap: () async {
//                                         Navigator.pop(context);
//                                         Navigator.pop(context);
//                                       },
//                                     );
//                                   });
//                             },
//                           ),
//                         ),
//                   const Spacer(),
//                   Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: IconWithRoundGradient(
//                           size: 20,
//                           iconData: !isFlashOn
//                               ? Icons.flash_on_rounded
//                               : Icons.flash_off_rounded,
//                           onTap: () async {
//                             isFlashOn = !isFlashOn;
//                             setState(() {});
//                             await BubblyCamera.flashOnOff;
//                           },
//                         ),
//                       ),
//                       isStartRecording
//                           ? const SizedBox()
//                           : Padding(
//                               padding: const EdgeInsets.only(top: 20),
//                               child: IconWithRoundGradient(
//                                 iconData: Icons.flip_camera_android_rounded,
//                                 size: 20,
//                                 onTap: () async {
//                                   isFront = !isFront;
//                                   await BubblyCamera.toggleCamera;
//                                   setState(() {});
//                                 },
//                               ),
//                             ),
//                       isRecordingStaring
//                           ? const SizedBox()
//                           : Visibility(
//                               visible: soundId == null || soundId!.isEmpty,
//                               child: InkWell(
//                                 onTap: () {
//                                   showModalBottomSheet(
//                                     context: context,
//                                     shape: const RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.vertical(
//                                             top: Radius.circular(15))),
//                                     backgroundColor: ColorRes.colorPrimaryDark,
//                                     isScrollControlled: true,
//                                     builder: (context) {
//                                       return MusicScreen(
//                                         (data, localMusic) async {
//                                           isMusicSelect = true;
//                                           _selectedMusic = data;
//                                           _localMusic = localMusic;
//                                           soundId = data?.soundId.toString();
//                                           setState(() {});
//                                         },
//                                       );
//                                     },
//                                   ).then((value) {
//                                     //   Provider.of<MyLoading>(context,
//                                     //           listen: false)
//                                     //       .setLastSelectSoundId('');
//                                   });
//                                 },
//                                 child: const Padding(
//                                   padding: EdgeInsets.only(top: 20),
//                                   child: ImageWithRoundGradient(icMusic, 11),
//                                 ),
//                               ),
//                             ),
//                     ],
//                   )
//                 ],
//               ),
//               const Spacer(),
//               isRecordingStaring
//                   ? const SizedBox()
//                   : Visibility(
//                       visible: !isMusicSelect,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SecondsTab(
//                             onTap: () {
//                               isSelected15s = true;
//                               totalSeconds = 15;
//                               setState(() {});
//                             },
//                             isSelected: isSelected15s,
//                             title: AppRes.fiftySecond,
//                           ),
//                           const SizedBox(width: 15),
//                           SecondsTab(
//                             onTap: () {
//                               isSelected15s = false;
//                               totalSeconds = 30;
//                               setState(() {});
//                             },
//                             isSelected: !isSelected15s,
//                             title: AppRes.thirtySecond,
//                           ),
//                         ],
//                       ),
//                     ),
//               const SizedBox(height: 5),
//               SafeArea(
//                 top: false,
//                 child: Container(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       isRecordingStaring
//                           ? SizedBox(
//                               width: 40,
//                               height: isMusicSelect ? 0 : 40,
//                             )
//                           : SizedBox(
//                               width: 40,
//                               height: isMusicSelect ? 0 : 40,
//                               child: IconWithRoundGradient(
//                                 iconData: Icons.image,
//                                 size: isMusicSelect ? 0 : 20,
//                                 onTap: () => _showFilePicker(),
//                               ),
//                             ),
//                       InkWell(
//                         onTap: () async {
//                           isStartRecording = !isStartRecording;
//                           isRecordingStaring = true;
//                           setState(() {});
//                           startProgress();
//                         },
//                         child: Container(
//                           height: 85,
//                           width: 85,
//                           decoration: const BoxDecoration(
//                               color: ColorRes.white, shape: BoxShape.circle),
//                           padding: const EdgeInsets.all(10.0),
//                           alignment: Alignment.center,
//                           child: isStartRecording
//                               ? const Icon(
//                                   Icons.pause,
//                                   color: AppColors.blue10,
//                                   size: 50,
//                                 )
//                               : Container(
//                                   decoration: BoxDecoration(
//                                     color: AppColors.blue10,
//                                     shape: isStartRecording
//                                         ? BoxShape.rectangle
//                                         : BoxShape.circle,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       Visibility(
//                         visible: !isStartRecording,
//                         replacement: const SizedBox(height: 38, width: 38),
//                         child: IconWithRoundGradient(
//                           iconData: Icons.check_circle_rounded,
//                           size: 20,
//                           onTap: () async {
//                             // log('message');
//                             await BubblyCamera.stopRecording;

//                             // if (!isRecordingStaring) {
//                             //   CommonUI.showToast(msg: LKey.videoIsToShort.tr);
//                             // } else {
//                             // await _stopAndMergeVideoForIos();
//                             //   // if (soundId != null &&
//                             //   //     soundId!.isNotEmpty &&
//                             //   //     Platform.isIOS) {

//                             //   // } else {

//                             //   // }
//                             // }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _bindBackgroundIsolate() {
//     final bool isSuccess = IsolateNameServer.registerPortWithName(
//         _port.sendPort, 'downloader_send_port');
//     if (!isSuccess) {
//       _unbindBackgroundIsolate();
//       _bindBackgroundIsolate();
//       return;
//     }
//     _port.listen((dynamic data) async {
//       final int status = data[1];

//       if (status == 3) {
//         Navigator.pop(context);
//         _audioPlayer = AudioPlayer();
//         isMusicSelect = true;
//         _localMusic = '${_localMusic!}/${widget.soundUrl!}';
//         setState(() {});
//       }
//     });
//   }

//   void _unbindBackgroundIsolate() {
//     IsolateNameServer.removePortNameMapping('downloader_send_port');
//   }

//   @pragma('vm:entry-point')
//   static void downloadCallback(String id, int status, int progress) {
//     final SendPort send =
//         IsolateNameServer.lookupPortByName('downloader_send_port')!;
//     send.send([id, status, progress]);
//   }

//   Future<String> _findLocalPath() async {
//     final directory = Platform.isAndroid
//         ? await getExternalStorageDirectory()
//         : await getApplicationDocumentsDirectory();
//     return directory!.path;
//   }

//   Future<void> downloadMusic() async {
//     _localMusic =
//         (await _findLocalPath()) + Platform.pathSeparator + UrlRes.camera;
//     final savedDir = Directory(_localMusic!);
//     final bool hasExisted = await savedDir.exists();
//     if (!hasExisted) {
//       savedDir.create();
//     }
//     if (File(_localMusic! + widget.soundUrl!).existsSync()) {
//       File(_localMusic! + widget.soundUrl!).deleteSync();
//     }
//     await FlutterDownloader.enqueue(
//       url: ConstRes.itemBaseUrl + widget.soundUrl!,
//       savedDir: _localMusic!,
//       showNotification: false,
//       openFileFromNotification: false,
//     );
//     CommonUI.showLoader(context);
//   }

//   // Recording
//   Future<void> startProgress() async {
//     if (timer == null) {
//       initProgress();
//     } else {
//       if (isStartRecording) {
//         initProgress();
//       } else {
//         cancelTimer();
//       }
//     }
//     if (isStartRecording) {
//       if (currentSecond == 0) {
//         // if (soundId != null && soundId!.isNotEmpty) {
//         _audioPlayer = AudioPlayer(playerId: '1');

//         await _audioPlayer?.play(
//           UrlSource(
//               'https://res.cloudinary.com/dxgbkcpvy/video/upload/v1734264731/iLoveYt_mp3cut.net_clrtwu.mp3'),
//           mode: PlayerMode.mediaPlayer,
//           ctx: const AudioContext(
//             android: AudioContextAndroid(isSpeakerphoneOn: true),
//             iOS: AudioContextIOS(
//               category: AVAudioSessionCategory.playAndRecord,
//               options: [
//                 AVAudioSessionOptions.allowAirPlay,
//                 AVAudioSessionOptions.allowBluetooth,
//                 AVAudioSessionOptions.allowBluetoothA2DP,
//                 AVAudioSessionOptions.defaultToSpeaker
//               ],
//             ),
//           ),
//         );
//         final totalSecond = await Future.delayed(
//             const Duration(milliseconds: 300),
//             () => _audioPlayer!.getDuration());
//         totalSeconds = totalSecond!.inSeconds.toDouble();
//         initProgress();
//         // }
//         await BubblyCamera.startRecording;
//       } else {
//         print('Audio Resume Recording');
//         await _audioPlayer?.resume();
//         await BubblyCamera.resumeRecording;
//       }
//     } else {
//       print('Audio Pause Recording');
//       await _audioPlayer?.pause();
//       await BubblyCamera.pauseRecording;
//     }
//     print('============ $currentSecond');
//   }

//   // Stop Merge For iOS
//   Future<void> _stopAndMergeVideoForIos({bool isAutoStop = false}) async {
//     print('_stopAndMergeVideoForIos');
//     CommonUI.showLoader(context);
//     if (isAutoStop) {
//       await BubblyCamera.pauseRecording;
//     }
//     // final audioFile = await downloadFile(
//     //     'https://res.cloudinary.com/dxgbkcpvy/video/upload/v1734264731/iLoveYt_mp3cut.net_clrtwu.mp3',
//     //     onProgressChanged: (progress) {});
//     // _trimAudioFile(audioFile.path);
//     // final String start = _formatDuration(Duration.zero);
//     // final String duration = _formatDuration(const Duration(seconds: 20));
//     // log(audioFile.path);
//     // final Directory tempDir = await getTemporaryDirectory();
//     // final String outputPath = '${tempDir.path}/replaced_audio.mp3';

//     // final String command =
//     //     'ffmpeg -ss 00:00:10 -t 00:00:20 -i ${audioFile.path} -c copy $outputPath';
//     // _audioPlayer = AudioPlayer(playerId: '3');
//     // await FFmpegKit.execute(command).then((path) {
//     //   _audioPlayer?.play(
//     //     DeviceFileSource(outputPath),
//     //     mode: PlayerMode.mediaPlayer,
//     //     ctx: const AudioContext(
//     //       android: AudioContextAndroid(isSpeakerphoneOn: true),
//     //       iOS: AudioContextIOS(
//     //         category: AVAudioSessionCategory.playAndRecord,
//     //         options: [
//     //           AVAudioSessionOptions.allowAirPlay,
//     //           AVAudioSessionOptions.allowBluetooth,
//     //           AVAudioSessionOptions.allowBluetoothA2DP,
//     //           AVAudioSessionOptions.defaultToSpeaker
//     //         ],
//     //       ),
//     //     ),
//     //   );
//     // });

//     await Future.delayed(const Duration(milliseconds: 500));
//     // log(audioFile.path);
//     await BubblyCamera.mergeAudioVideo('');
//   }

//   Future<void> _trimAudioFile(String path) async {
//     try {
//       final prefix.AudioPlayer justAudio = prefix.AudioPlayer();
//       // Tải tệp âm thanh gốc
//       await justAudio.setFilePath(path);

//       // Lấy thư mục tạm để lưu tệp đã cắt
//       final Directory tempDir = await getTemporaryDirectory();
//       final String tempPath = '${tempDir.path}/trimmed_audio.mp3';

//       // Cắt 15 giây đầu tiên
//       await justAudio.setClip(
//         start: const Duration(),
//         end: const Duration(seconds: 15),
//       );

//       // Xuất tệp đã cắt
//       await justAudio.seek(Duration.zero);
//       await justAudio.play();

//       // Lưu tệp đã cắt (trong thực tế, bạn cần một phương pháp xuất chuyên dụng)
//     } catch (e) {
//       print('Lỗi khi cắt file âm thanh: $e');
//     }
//   }

//   String _formatDuration(Duration duration) {
//     return '${duration.inHours.toString().padLeft(2, '0')}:'
//         '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
//         '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
//   }

//   Future<File> downloadFile(String url,
//       {required Function(double) onProgressChanged}) async {
//     try {
//       // Get temporary directory
//       final dir = await getTemporaryDirectory();
//       final fileName =
//           'downloaded_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
//       final filePath = '${dir.path}/$fileName';

//       // Initialize Dio for download
//       final dio = Dio();
//       await dio.download(
//         url,
//         filePath,
//         onReceiveProgress: (receivedBytes, totalBytes) {
//           // Calculate and report download progress
//           final double progress = receivedBytes / totalBytes;
//           onProgressChanged(progress);
//         },
//       );

//       return File(filePath);
//     } catch (e) {
//       throw Exception('Download failed: ${e.toString()}');
//     }
//   }

//   Future<void> replaceVideoAudio(
//       {required String videoPath, required String onlineAudioUrl}) async {
//     try {
//       // 1. Xác định duration của video
//       // final MediaInfo videoInfo = await VideoCompress.getMediaInfo(videoPath);
//       const int videoDuration = 5000; // milliseconds

//       // 2. Download audio file
//       final audioFile =
//           await downloadFile(onlineAudioUrl, onProgressChanged: (progress) {
//         log(progress.toString());
//       });

//       // 3. Lấy thư mục tạm
//       final Directory tempDir = await getTemporaryDirectory();
//       final String outputPath =
//           '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}replaced_audio_video.mp4';
//       final String trimmedAudioPath =
//           '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}trimmed_audio.mp4';

//       // 4. Cắt audio bằng với duration video
//       final String ffmpegTrimCommand =
//           '-i "${audioFile.path}" -t 5 "$trimmedAudioPath"';

//       await FFmpegKit.execute(ffmpegTrimCommand).then((value) async {
//         _audioPlayer = AudioPlayer(playerId: '1');
//         await _audioPlayer?.play(
//           DeviceFileSource(trimmedAudioPath),
//           mode: PlayerMode.mediaPlayer,
//           ctx: const AudioContext(
//             android: AudioContextAndroid(isSpeakerphoneOn: true),
//             iOS: AudioContextIOS(
//               category: AVAudioSessionCategory.playAndRecord,
//               options: [
//                 AVAudioSessionOptions.allowAirPlay,
//                 AVAudioSessionOptions.allowBluetooth,
//                 AVAudioSessionOptions.allowBluetoothA2DP,
//                 AVAudioSessionOptions.defaultToSpeaker
//               ],
//             ),
//           ),
//         );
//       });

//       // // 5. Thay thế âm thanh trong video
//       // final String ffmpegReplaceCommand =
//       //     '-i "$videoPath" -i "$trimmedAudioPath" -map 0:v -map 1:a -c:v copy -c:a aac "$outputPath"';

//       // await FFmpegKit.execute(ffmpegReplaceCommand).then((session) async {
//       //   Navigator.pop(context);
//       //   Navigator.pop(context);
//       //   Navigator.push(
//       //     context,
//       //     MaterialPageRoute(builder: (context) {
//       //       return PreviewScreen(
//       //         postVideo: outputPath,
//       //         thumbNail: "$tempDir${Platform.pathSeparator}thumbNail.png",
//       //         sound: '',
//       //         duration: videoDuration ~/ 1000,
//       //       );
//       //     }),
//       //   );
//       // });
//     } catch (e) {
//       log(e.toString());
//     }
//   }

//   Future<void> gotoPreviewScreen(String pathOfVideo) async {
//     if (soundId != null && soundId!.isNotEmpty) {
//       CommonUI.showLoader(context);
//       final String f = await _findLocalPath();
//       if (!Platform.isAndroid) {
//         FFmpegKit.execute(
//                 '-i $pathOfVideo -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
//             .then(
//           (returnCode) async {
//             Navigator.pop(context);
//             Navigator.pop(context);
//             Navigator.pop(context);
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PreviewScreen(
//                   postVideo: pathOfVideo,
//                   thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
//                   soundId: soundId,
//                   duration: currentSecond.toInt(),
//                 ),
//               ),
//             );
//           },
//         );
//       } else {
//         if (Platform.isAndroid && isFront) {
//           await FFmpegKit.execute(
//               '-i "$pathOfVideo" -y -vf hflip "$f${Platform.pathSeparator}out1.mp4"');
//           FFmpegKit.execute(
//                   "-i \"$f${Platform.pathSeparator}out1.mp4\" -i $_localMusic -y -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest $f${Platform.pathSeparator}out.mp4")
//               .then((returnCode) {
//             FFmpegKit.execute(
//                     '-i $f${Platform.pathSeparator}out.mp4 -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
//                 .then(
//               (returnCode) async {
//                 Navigator.pop(context);
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PreviewScreen(
//                       postVideo: '$f${Platform.pathSeparator}out.mp4',
//                       thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
//                       soundId: soundId,
//                       duration: currentSecond.toInt(),
//                     ),
//                   ),
//                 );
//               },
//             );
//           });
//         } else {
//           FFmpegKit.execute(
//                   "-i $pathOfVideo -i $_localMusic -y -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest $f${Platform.pathSeparator}out.mp4")
//               .then((returnCode) {
//             FFmpegKit.execute(
//                     '-i $f${Platform.pathSeparator}out.mp4 -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
//                 .then(
//               (returnCode) async {
//                 Navigator.pop(context);
//                 Navigator.pop(context);

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PreviewScreen(
//                       postVideo: '$f${Platform.pathSeparator}out.mp4',
//                       thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
//                       soundId: soundId,
//                       duration: currentSecond.toInt(),
//                     ),
//                   ),
//                 );
//               },
//             );
//           });
//         }
//       }
//       return;
//     }
//     CommonUI.showLoader(context);
//     final String f = await _findLocalPath();
//     final String soundPath =
//         '$f${Platform.pathSeparator + DateTime.now().millisecondsSinceEpoch.toString()}sound.wav';
//     await FFmpegKit.execute('-i "$pathOfVideo" -y $soundPath');
//     if (Platform.isAndroid && isFront) {
//       await FFmpegKit.execute(
//           '-i "$pathOfVideo" -y -vf hflip "$f${Platform.pathSeparator}out1.mp4"');
//       FFmpegKit.execute(
//               '-i "$f${Platform.pathSeparator}out1.mp4" -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
//           .then(
//         (returnCode) async {
//           Navigator.pop(context);
//           Navigator.pop(context);
//           print(' 🛑 Recording Video 🛑');
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PreviewScreen(
//                 postVideo: '$f${Platform.pathSeparator}out1.mp4',
//                 thumbNail: '$f${Platform.pathSeparator}thumbNail.png',
//                 sound: soundPath,
//                 duration: currentSecond.toInt(),
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       FFmpegKit.execute(
//               '-i "$pathOfVideo" -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
//           .then(
//         (returnCode) async {
//           print('Recording Video without Sound 🛑 ');
//           Navigator.pop(context);
//           Navigator.pop(context);
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) {
//               return PreviewScreen(
//                 postVideo: pathOfVideo,
//                 thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
//                 sound: soundPath,
//                 duration: currentSecond.toInt(),
//               );
//             }),
//           );
//         },
//       );
//     }
//   }

//   Future<void> _showFilePicker() async {
//     HapticFeedback.mediumImpact();
//     CommonUI.showLoader(context);
//     _picker
//         .pickVideo(
//             source: ImageSource.gallery,
//             maxDuration: const Duration(minutes: 1))
//         .then(
//       (value) async {
//         Navigator.pop(context);
//         if (value != null && value.path.isNotEmpty) {
//           final VideoData? a = await _flutterVideoInfo.getVideoInfo(value.path);
//           if (a!.filesize! / 1000000 > 40) {
//             showDialog(
//               context: context,
//               builder: (mContext) => ConfirmationDialog(
//                 aspectRatio: 1.8,
//                 title1: LKey.tooLargeVideo,
//                 title2: LKey.thisVideoIsGreaterThan50MbNPleaseSelectAnother.tr,
//                 positiveText: LKey.selectAnother.tr,
//                 onPositiveTap: () {
//                   _showFilePicker();

//                   Navigator.pop(context);
//                 },
//               ),
//             );
//             return;
//           }
//           if ((a.duration! / 1000) > 180) {
//             showDialog(
//                 context: context,
//                 builder: (mContext) {
//                   return ConfirmationDialog(
//                     aspectRatio: 1.8,
//                     title1: LKey.tooLongVideo.tr,
//                     title2:
//                         LKey.thisVideoIsGreaterThan1MinNPleaseSelectAnother.tr,
//                     positiveText: LKey.selectAnother,
//                     onPositiveTap: () {
//                       Navigator.pop(context);
//                       _showFilePicker();
//                     },
//                   );
//                 });
//             return;
//           }
//           CommonUI.showLoader(context);
//           final String f = await _findLocalPath();
//           await FFmpegKit.execute(
//               '-i "${value.path}" -y $f${Platform.pathSeparator}sound.wav');
//           FFmpegKit.execute(
//                   '-i "${value.path}" -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
//               .then(
//             (returnCode) async {
//               Navigator.pop(context);
//               Navigator.pop(context);

//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PreviewScreen(
//                     postVideo: value.path,
//                     thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
//                     sound: "$f${Platform.pathSeparator}sound.wav",
//                     duration: (a.duration ?? 0) ~/ 1000,
//                   ),
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }

//   void initProgress() {
//     timer?.cancel();
//     timer = null;

//     timer = Timer.periodic(const Duration(milliseconds: 10), (time) async {
//       currentSecond += 0.01;
//       currentPercentage = (100 * currentSecond) / totalSeconds;
//       if (totalSeconds.toInt() <= currentSecond.toInt()) {
//         timer?.cancel();
//         timer = null;
//         if (soundId != null && soundId!.isNotEmpty && Platform.isIOS) {
//           _stopAndMergeVideoForIos(isAutoStop: true);
//         } else {
//           await BubblyCamera.stopRecording;
//         }
//       }
//       setState(() {});
//     });
//   }

//   void cancelTimer() {
//     timer?.cancel();
//     timer = null;
//   }
// }

// class IconWithRoundGradient extends StatelessWidget {
//   final IconData iconData;
//   final double size;
//   final Function? onTap;

//   const IconWithRoundGradient(
//       {required this.iconData, required this.size, super.key, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return ClipOval(
//       child: InkWell(
//         onTap: () => onTap?.call(),
//         child: Container(
//           height: 38,
//           width: 38,
//           decoration: const BoxDecoration(color: AppColors.blue10),
//           child: Icon(iconData, color: ColorRes.white, size: size),
//         ),
//       ),
//     );
//   }
// }

// class ImageWithRoundGradient extends StatelessWidget {
//   final String imageData;
//   final double padding;

//   const ImageWithRoundGradient(this.imageData, this.padding, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ClipOval(
//       child: Container(
//         height: 38,
//         width: 38,
//         decoration: const BoxDecoration(color: AppColors.blue10),
//         child: Padding(
//           padding: EdgeInsets.all(padding),
//           child: Image(
//             image: AssetImage(imageData),
//             color: ColorRes.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
