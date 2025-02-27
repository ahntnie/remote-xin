import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/all.dart';
import '../../../../repositories/all.dart';
import '../../../resource/styles/styles.dart';
import '../custom_view/app_bar_custom.dart';
import '../modal/setting/setting.dart';
import '../utils/colors.dart';
import '../utils/session_manager.dart';
import 'upload/upload_screen.dart';

class PreviewScreen extends StatefulWidget {
  final String? postVideo;
  final String? thumbNail;
  final String? sound;
  final int? soundId;
  final int duration;

  const PreviewScreen(
      {required this.duration,
      super.key,
      this.postVideo,
      this.thumbNail,
      this.sound,
      this.soundId});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  VideoPlayerController? _videoPlayerController;
  SessionManager sessionManager = SessionManager();

  SettingData? settingData;
  String mediaId = '';

  bool isLoading = false;

  @override
  void initState() {
    prefData();
    initPlayVideo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: InkWell(
        onTap: () {
          if (_videoPlayerController!.value.isPlaying) {
            _videoPlayerController?.pause();
          } else {
            _videoPlayerController?.play();
          }
          setState(() {});
        },
        child: Column(
          children: [
            AppBarCustom(title: context.l10n.short__preview_screen),
            Container(
                height: 0.3,
                color: Colors.black,
                margin: const EdgeInsets.only()),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                      aspectRatio:
                          _videoPlayerController?.value.aspectRatio ?? 2 / 3,
                      child: VideoPlayer(_videoPlayerController!)),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: onCheckButtonClick,
                      child: Container(
                          height: 50,
                          width: 50,
                          margin: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: AppColors.blue10),
                          child: const Icon(Icons.check_rounded,
                              color: ColorRes.white)),
                    ),
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onCheckButtonClick() async {
    try {
      if (!isLoading) {
        if (widget.postVideo != null) {
          setState(() {
            isLoading = true;
          });
          // final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
          //   widget.postVideo ?? '',
          //   quality:
          //       VideoQuality.Res640x480Quality, // Chọn mức chất lượng phù hợp
          // );
          // if (mediaInfo != null) {
          final data = await Get.find<NewsfeedRepository>()
              .createFile(File(widget.postVideo ?? ''));
          final thumbnailData = await Get.find<NewsfeedRepository>()
              .createFile(File(widget.thumbNail ?? ''));
          setState(() {
            isLoading = false;
          });

          navigateScreen(data.path, thumbnailData.path);
          // }
        }
      }
    } catch (e) {
      ViewUtil.showToast(title: 'Error', message: e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> checkVideoModeration() async {
  //   CommonUI.showLoader(context);
  //   final NudityMediaId nudityMediaId = await ApiService()
  //       .checkVideoModerationApiMoreThenOneMinutes(
  //           apiUser: settingData?.sightEngineApiUser ?? '',
  //           apiSecret: settingData?.sightEngineApiSecret ?? '',
  //           file: File(widget.postVideo ?? ''));
  //   Navigator.pop(context);

  //   await Future.delayed(Duration.zero);

  //   if (nudityMediaId.status == 'success') {
  //     mediaId = nudityMediaId.media?.id ?? '';
  //     getVideoModerationChecker();
  //   } else {
  //     print('object Dhruv Kathiriya');
  //     CommonUI.showToast(
  //         msg: nudityMediaId.error?.message ?? '',
  //         backGroundColor: ColorRes.red,
  //         duration: 2);
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => const MainScreen()),
  //         (route) => false);
  //   }
  // }

  void navigateScreen(String postVideo, String thumbnail) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return UploadScreen(
            postVideo: postVideo,
            thumbNail: thumbnail,
            soundId: widget.soundId,
            sound: widget.sound);
      },
    );
  }

  Future<void> prefData() async {
    await sessionManager.initPref();
    settingData = sessionManager.getSetting()?.data;
    setState(() {});
  }

  void initPlayVideo() {
    print('File Path : ${widget.postVideo}');
    _videoPlayerController = VideoPlayerController.file(File(widget.postVideo!))
      ..initialize().then((_) {
        _videoPlayerController?.play();
        setState(() {});
        _videoPlayerController?.setLooping(true);
      });
  }

  // Future<void> getVideoModerationChecker() async {
  //   final List<double> nudityList = [];
  //   if (Get.isDialogOpen == false) {
  //     Get.dialog(const LoaderDialog());
  //   }

  //   final NudityChecker nudityChecker = await ApiService().getOnGoingVideoJob(
  //       mediaId: mediaId,
  //       apiUser: settingData?.sightEngineApiUser ?? '',
  //       apiSecret: settingData?.sightEngineApiSecret ?? '');

  //   if (nudityChecker.status == 'failure') {
  //     Get.back();
  //     CommonUI.showToast(
  //         msg: nudityChecker.error?.message ?? '',
  //         backGroundColor: ColorRes.red,
  //         duration: 2);
  //   }

  //   if (nudityChecker.output?.data?.status == 'ongoing') {
  //     getVideoModerationChecker();
  //     return;
  //   }
  //   Get.back();

  //   if (nudityChecker.output?.data?.status == 'finished') {
  //     nudityChecker.output?.data?.frames?.forEach((element) {
  //       nudityList.add(element.nudity?.raw ?? 0.0);
  //       nudityList.add(element.weapon ?? 0.0);
  //       nudityList.add(element.alcohol ?? 0.0);
  //       nudityList.add(element.drugs ?? 0.0);
  //       nudityList.add(element.medicalDrugs ?? 0.0);
  //       nudityList.add(element.recreationalDrugs ?? 0.0);
  //       nudityList.add(element.weaponFirearm ?? 0.0);
  //       nudityList.add(element.weaponKnife ?? 0.0);
  //     });
  //     print(nudityList);
  //     if (nudityList.reduce(max) > 0.7) {
  //       CommonUI.showToast(
  //           msg:
  //               'This media contains sensitive content which is not allowed to post on the platform!',
  //           duration: 2,
  //           backGroundColor: ColorRes.red);
  //       Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const MainScreen(),
  //           ),
  //           (route) => false);
  //     } else {
  //       navigateScreen();
  //     }
  //   }

  //   if (nudityChecker.output?.data?.status == 'failure') {
  //     CommonUI.showToast(
  //         msg: nudityChecker.error?.message ?? '',
  //         duration: 2,
  //         backGroundColor: ColorRes.red);
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const MainScreen(),
  //         ),
  //         (route) => false);
  //   }
  // }

  @override
  void dispose() {
    print('Dispose');
    _videoPlayerController!.dispose();
    _videoPlayerController = null;
    super.dispose();
  }
}
