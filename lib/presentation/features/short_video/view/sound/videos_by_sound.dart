import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

import '../../../../../core/all.dart';
import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../custom_view/common_ui.dart';
import '../../languages/languages_keys.dart';
import '../../modal/user_video/user_video.dart';
import '../../utils/colors.dart';
import '../../utils/font_res.dart';
import '../../utils/key_res.dart';
import '../../utils/session_manager.dart';
import '../camera/camera_screen.dart';
import '../profile/item_post.dart';

class VideosBySoundScreen extends StatefulWidget {
  final Data? videoData;

  const VideosBySoundScreen(this.videoData, {super.key});

  @override
  _VideosBySoundScreenState createState() => _VideosBySoundScreenState();
}

class _VideosBySoundScreenState extends State<VideosBySoundScreen> {
  int? count = 0;
  bool isLoading = false;
  bool isPlay = false;
  bool isFav = true;
  final ScrollController _scrollController = ScrollController();
  List<Data> postList = [];
  AudioPlayer audioPlayer = AudioPlayer(playerId: '1');
  bool isLogin = false;
  bool hasMoreData = true;
  int page = 1;
  final shortVideoRepo = Get.find<ShortVideoRepository>();

  @override
  void initState() {
    initIsFav();
    _scrollController.addListener(_scrollListener);
    callApiForGetPostsBySoundId();
    super.initState();
  }

  void _scrollListener() {
    // Kiểm tra khi cuộn gần đến cuối danh sách
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Nếu không đang load và còn dữ liệu
      if (!isLoading && hasMoreData) {
        callApiForGetPostsBySoundId();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        // titleWidget: Text(
        //   'Sound Videos',
        //   style: AppTextStyles.s22w600.text2Color,
        // ),
        titleType: AppBarTitle.none,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            margin: const EdgeInsets.all(15),
            child: Row(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: AppNetworkImage(
                            widget.videoData!.soundImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )),
                      IconWithRoundGradient(
                        iconData: isPlay
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 35,
                        onTap: () async {
                          if (!isPlay) {
                            await audioPlayer.play(
                              UrlSource(widget.videoData!.sound ?? ''),
                              mode: PlayerMode.mediaPlayer,
                              ctx: const AudioContext(
                                android:
                                    AudioContextAndroid(isSpeakerphoneOn: true),
                                iOS: AudioContextIOS(
                                  category:
                                      AVAudioSessionCategory.playAndRecord,
                                  options: [
                                    AVAudioSessionOptions.allowAirPlay,
                                    AVAudioSessionOptions.allowBluetooth,
                                    AVAudioSessionOptions.allowBluetoothA2DP,
                                    AVAudioSessionOptions.defaultToSpeaker
                                  ],
                                ),
                              ),
                            );
                            audioPlayer.setReleaseMode(ReleaseMode.loop);
                            isPlay = true;
                          } else {
                            audioPlayer.release();
                            isPlay = false;
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 25,
                        child: Marquee(
                          text: widget.videoData!.soundTitle!,
                          style: const TextStyle(
                              fontFamily: FontRes.fNSfUiMedium,
                              fontSize: 22,
                              color: Colors.black),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          blankSpace: 50.0,
                          // pauseAfterRound: const Duration(seconds: 2),
                          // accelerationDuration: const Duration(seconds: 1),
                          accelerationCurve: Curves.linear,
                          // decelerationDuration:
                          //     const Duration(milliseconds: 500),
                          decelerationCurve: Curves.easeOut,
                        ),
                      ),
                      AppSpacing.gapH12,
                      Text(
                        '${postList.length} ${LKey.videos.tr}',
                        style: const TextStyle(
                            color: ColorRes.colorTextLight, fontSize: 16),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     isFav = !isFav;
                      //     sessionManager.saveFavouriteMusic(
                      //         widget.videoData!.soundId.toString());
                      //     setState(() {});
                      //   },
                      //   child: AnimatedContainer(
                      //     decoration: BoxDecoration(
                      //       gradient: LinearGradient(
                      //         colors: isFav
                      //             ? [
                      //                 ColorRes.colorPrimary,
                      //                 ColorRes.colorPrimary
                      //               ]
                      //             : [ColorRes.colorTheme, ColorRes.colorPink],
                      //       ),
                      //       borderRadius:
                      //           const BorderRadius.all(Radius.circular(6)),
                      //     ),
                      //     height: 30,
                      //     width: isFav ? 130 : 110,
                      //     duration: const Duration(milliseconds: 500),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Icon(
                      //           !isFav
                      //               ? Icons.bookmark_border_rounded
                      //               : Icons.bookmark_rounded,
                      //           color: ColorRes.white,
                      //           size: !isFav ? 21 : 18,
                      //         ),
                      //         const SizedBox(width: 5),
                      //         Text(
                      //           isFav ? LKey.unFavourite.tr : LKey.favourite.tr,
                      //           style: const TextStyle(
                      //               fontFamily: FontRes.fNSfUiBold,
                      //               color: ColorRes.white),
                      //         ),
                      //         const SizedBox(width: 2),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const LoaderDialog()
                : postList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.l10n.short__nothing_video,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: FontRes.fNSfUiBold,
                                  color: ColorRes.colorTextLight),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1 / 1.3,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(left: 10, bottom: 20),
                        itemCount: postList.length,
                        itemBuilder: (context, index) {
                          if (index == postList.length) {
                            return _buildLoadingIndicator();
                          }
                          return ItemPost(
                            list: postList,
                            data: postList[index],
                            soundId: widget.videoData!.soundId.toString(),
                            type: 3,
                            onTap: () async {
                              await audioPlayer.pause();
                              isPlay = !isPlay;
                              setState(() {});
                            },
                            onComment: (index, count) {},
                            onLike: (index, isLiked, count) {},
                            onDelete: (p0) {},
                            onPinned: (id, value) {},
                            onBookmark: (index, value) {},
                            onFollowed: (index, value) {},
                          );
                        },
                      ),
          ),
          // FittedBox(
          //   child: Container(
          //     height: 45,
          //     margin:
          //         EdgeInsets.only(bottom: AppBar().preferredSize.height / 2),
          //     padding: const EdgeInsets.symmetric(horizontal: 30),
          //     decoration: const BoxDecoration(
          //       color: ColorRes.colorTheme,
          //       borderRadius: BorderRadius.all(Radius.circular(50)),
          //     ),
          //     child: InkWell(
          //       onTap: () {
          //         audioPlayer.pause();
          //         isPlay = false;
          //         setState(() {});
          //         if (SessionManager.userId == -1 || !isLogin) {
          //           showModalBottomSheet(
          //             backgroundColor: Colors.transparent,
          //             shape: const RoundedRectangleBorder(
          //               borderRadius: BorderRadius.vertical(
          //                 top: Radius.circular(20),
          //               ),
          //             ),
          //             isScrollControlled: true,
          //             context: context,
          //             builder: (context) {
          //               return LoginSheet();
          //             },
          //           ).then((value) {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => CameraScreen(
          //                   soundId: widget.videoData!.soundId.toString(),
          //                   soundTitle: widget.videoData!.soundTitle,
          //                   soundUrl: widget.videoData!.sound,
          //                 ),
          //               ),
          //             ).then((value) async {
          //               await Future.delayed(const Duration(seconds: 1));
          //               await BubblyCamera.cameraDispose;
          //             });
          //           });
          //         } else {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => CameraScreen(
          //                   soundId: widget.videoData?.soundId.toString(),
          //                   soundTitle: widget.videoData?.soundTitle,
          //                   soundUrl: widget.videoData?.sound),
          //             ),
          //           ).then((value) async {
          //             await Future.delayed(const Duration(seconds: 1));
          //             await BubblyCamera.cameraDispose;
          //           });
          //         }
          //       },
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const Icon(
          //             Icons.play_circle_filled_rounded,
          //             color: ColorRes.white,
          //             size: 30,
          //           ),
          //           const SizedBox(width: 5),
          //           Text(
          //             LKey.useThisSound.tr,
          //             style: const TextStyle(
          //                 fontFamily: FontRes.fNSfUiSemiBold,
          //                 fontSize: 16,
          //                 color: ColorRes.white),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return hasMoreData
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          )
        : Container();
  }

  void callApiForGetPostsBySoundId() {
    isLoading = true;
    shortVideoRepo
        .getPostListBySoundId(widget.videoData!.soundId ?? 0, page)
        .then((value) {
      isLoading = false;
      postList.addAll(value);
      setState(() {
        if (value.isEmpty) {
          hasMoreData = false;
        } else {
          postList.addAll(value);
          page++; // Tăng số trang
        }
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  SessionManager sessionManager = SessionManager();

  Future<void> initIsFav() async {
    await sessionManager.initPref();
    isLogin = sessionManager.getBool(KeyRes.login) ?? false;
    isFav = sessionManager
        .getFavouriteMusic()
        .contains(widget.videoData!.soundId.toString());
    setState(() {});
  }
}
