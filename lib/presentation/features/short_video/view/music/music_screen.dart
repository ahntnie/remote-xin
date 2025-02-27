import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../core/all.dart';
import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../resource/styles/styles.dart';
import '../../custom_view/common_ui.dart';
import '../../languages/languages_keys.dart';
import '../../modal/sound/sound.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/url_res.dart';
import 'search_music.dart';
import 'widget/discover_page.dart';

class MusicScreen extends StatefulWidget {
  final Function(SoundList) onSelectMusic;

  const MusicScreen(this.onSelectMusic, {super.key});

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  PageController pageController = PageController();
  FocusNode searchFocusNode = FocusNode();
  List<SoundList> soundList = [];
  bool isPlay = false;
  SoundList? lastSoundListData;

  AudioPlayer audioPlayer = AudioPlayer();
  Function(String)? onSearchChangeValue;

  String _localPath = '';
  final ReceivePort _port = ReceivePort();
  final shortVideoRepo = Get.find<ShortVideoRepository>();
  @override
  void initState() {
    searchFocusNode.addListener(() {
      // Provider.of<MyLoading>(context, listen: false)
      //     .setIsSearchMusic(searchFocusNode.hasFocus);
      // soundList = [];
    });
    // pageController = PageController(
    //     initialPage:
    //         Provider.of<MyLoading>(context, listen: false).getMusicPageIndex);
    // _bindBackgroundIsolate();
    getListMusic();
    super.initState();
  }

  Future getListMusic() async {
    soundList = await shortVideoRepo.getListSound();
    setState(() {});
  }

  void _bindBackgroundIsolate() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      final int status = data[1];
      setState(() {});

      // if (status == 3) {
      //   widget.onSelectMusic(
      //       lastSoundListData, _localPath + lastSoundListData!.sound!);
      //   Navigator.pop(context);
      //   Navigator.pop(context);
      // }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, MyLoading myLoading, child) {
      return Container(
        height:
            MediaQuery.of(context).size.height - AppBar().preferredSize.height,
        decoration: const BoxDecoration(
            color: ColorRes.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Row(
              children: [
                // Visibility(
                //   visible: soundList.isNotEmpty && myLoading.isSearchMusic,
                //   child: InkWell(
                //     onTap: () {
                //       if (myLoading.musicSearchText.isEmpty) {
                //         FocusScope.of(context).unfocus();
                //         myLoading.setIsSearchMusic(false);
                //         myLoading.setLastSelectSoundId("");
                //         soundList = [];
                //         audioPlayer.release();
                //       }
                //     },
                //     child: Container(
                //       width: 45,
                //       margin: EdgeInsets.only(left: 15, top: 15),
                //       child: Text(LKey.back.tr),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        left: soundList.isNotEmpty ? 0 : 15,
                        top: 15,
                        right: 15),
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                    height: 45,
                    decoration: const BoxDecoration(
                      color: ColorRes.greyShade100,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        onSearchChangeValue!(value);
                        myLoading.setMusicSearchText(value);
                        myLoading.setLastSelectSoundId('');
                      },
                      onTap: () {
                        audioPlayer.release();
                      },
                      focusNode: searchFocusNode,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: LKey.search.tr,
                          hintStyle:
                              AppTextStyles.s16w500.toColor(Colors.grey)),
                      cursorColor: ColorRes.colorTextLight,
                    ),
                  ),
                ),
                Visibility(
                  visible: soundList.isEmpty && myLoading.isSearchMusic,
                  child: InkWell(
                    onTap: () {
                      if (myLoading.musicSearchText.isEmpty) {
                        FocusScope.of(context).unfocus();
                        audioPlayer.release();
                        myLoading.setIsSearchMusic(false);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 15),
                      width: 60,
                      child: Text(
                        myLoading.musicSearchText.isNotEmpty
                            ? LKey.search.tr
                            : LKey.cancel.tr,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Visibility(
            //     visible: !myLoading.isSearchMusic,
            //     child: Container(
            //       margin: const EdgeInsets.symmetric(vertical: 10),
            //       child: Row(
            //         children: [
            //           Expanded(
            //             child: InkWell(
            //               onTap: () {
            //                 pageController.animateToPage(0,
            //                     duration: const Duration(milliseconds: 200),
            //                     curve: Curves.linear);
            //               },
            //               child: Center(
            //                 child: Text(
            //                   LKey.discover.tr,
            //                   style: TextStyle(
            //                     color: myLoading.getMusicPageIndex == 0
            //                         ? ColorRes.colorPink
            //                         : ColorRes.colorTextLight,
            //                     fontSize: 16,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             child: InkWell(
            //               onTap: () {
            //                 pageController.animateToPage(1,
            //                     duration: const Duration(milliseconds: 200),
            //                     curve: Curves.linear);
            //               },
            //               child: Center(
            //                 child: Text(
            //                   LKey.favourite.tr,
            //                   style: TextStyle(
            //                     color: myLoading.getMusicPageIndex == 1
            //                         ? ColorRes.colorPink
            //                         : ColorRes.colorTextLight,
            //                     fontSize: 16,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     )),
            SizedBox(height: myLoading.isSearchMusic ? 10 : 0),
            Container(
              height: 0.2,
              color: ColorRes.colorTextLight,
            ),
            const SizedBox(height: 5),
            Expanded(
                child: !myLoading.isSearchMusic
                    ?
                    // PageView(
                    //     controller: pageController,
                    //     onPageChanged: (value) {
                    //       myLoading.setLastSelectSoundId('');
                    //       myLoading.setMusicPageIndex(value);
                    //       audioPlayer.release();
                    //     },
                    //     children: [
                    //       DiscoverPage(
                    //         onMoreClick: (value) {
                    //           soundList = value;
                    //           myLoading.setIsSearchMusic(true);
                    //         },
                    //         onPlayClick: (data) {
                    //           playMusic(data, 1, myLoading);
                    //         },
                    //       ),
                    //       FavouritePage(
                    //         onClick: (data) {
                    //           playMusic(data, 2, myLoading);
                    //         },
                    //       ),
                    //     ],
                    //   )
                    DiscoverPage(
                        soundList: soundList,
                        onMoreClick: (value) {
                          soundList = value;
                          myLoading.setIsSearchMusic(true);
                        },
                        onPlayClick: (data) {
                          playMusic(data, 1, myLoading);
                        },
                        soundSelect: (p0) {
                          widget.onSelectMusic(p0);
                        },
                      )
                    : SearchMusic(
                        onSoundClick: (data) {
                          playMusic(data, 3, myLoading);
                        },
                        onSearchTextChange: onSearchChange,
                        soundList: soundList,
                      )),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    audioPlayer.release();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  Future<void> playMusic(SoundList data, int type, MyLoading myLoading) async {
    if (myLoading.isDownloadClick) {
      CommonUI.showLoader(context);
      myLoading.setIsDownloadClick(false);
      _localPath =
          (await _findLocalPath()) + Platform.pathSeparator + UrlRes.camera;

      final savedDir = Directory(_localPath);

      final bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }
      if (File(savedDir.path + data.sound!).existsSync()) {
        File(savedDir.path + data.sound!).deleteSync();
      }
      await FlutterDownloader.enqueue(
        url: ConstRes.itemBaseUrl + data.sound!,
        savedDir: _localPath,
      );
      return;
    }
    if (lastSoundListData == data) {
      if (isPlay) {
        isPlay = false;
        audioPlayer.pause();
      } else {
        isPlay = true;
        audioPlayer.resume();
      }
      myLoading.setLastSelectSoundIsPlay(isPlay);
      return;
    }
    lastSoundListData = data;
    myLoading.setLastSelectSoundId(lastSoundListData!.sound! + type.toString());
    myLoading.setLastSelectSoundIsPlay(true);
    // if (audioPlayer != null) {
    //   audioPlayer?.release();
    // }
    audioPlayer
        .play(UrlSource("${ConstRes.itemBaseUrl}${lastSoundListData?.sound}"));
    isPlay = true;
    setState(() {});
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    print(directory?.path);
    return '${directory?.path}';
  }

  onSearchChange(Function(String p1) p1) {
    onSearchChangeValue = p1;
  }
}
