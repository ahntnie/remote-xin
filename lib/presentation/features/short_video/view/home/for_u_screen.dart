import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/enums/item_video_from_page_enums.dart';
import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';
import '../../modal/user_video/user_video.dart';
import '../../utils/const_res.dart';
import '../../utils/url_res.dart';
import '../video/item_video.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  _ForYouScreenState createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen>
    with AutomaticKeepAliveClientMixin {
  List<Data> mList = [];
  PageController pageController = PageController();
  int focusedIndex = 0;
  Map<int, VideoPlayerController> controllers = {};
  bool isLoading = false;
  int pageIndex = 1;
  final shortVideoRepo = Get.find<ShortVideoRepository>();

  @override
  void initState() {
    loadCacheVideo();
    super.initState();
  }

  Future refresh() async {
    callApiForYou(
      (p0) {
        initVideoPlayer();
      },
      true,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      color: AppColors.blue10,
      backgroundColor: Colors.white,
      onRefresh: () {
        return refresh();
      },
      child: mList.isEmpty
          ? Container(
              color: Colors.black,
            )
          : PageView.builder(
              controller: pageController,
              itemCount: mList.length,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final Data data = mList[index];
                return ItemVideo(
                  type: ItemVideoFromPageEnum.home,
                  videoData: data,
                  videoPlayerController: controllers[index],
                  onLike: (id, liked, count) {
                    if (liked) {
                      mList[index] = mList[index]
                          .copyWith(videoLikesOrNot: 1, postLikesCount: count);
                    } else {
                      mList[index] = mList[index]
                          .copyWith(videoLikesOrNot: 0, postLikesCount: count);
                    }
                  },
                  onComment: (id, value) {
                    mList[index] =
                        mList[index].copyWith(postCommentsCount: value);
                  },
                  onDelete: (postId) {
                    refresh();
                  },
                  onBookmark: (id, value) {
                    final indexBookmark =
                        mList.indexWhere((item) => item.postId == id);
                    log(indexBookmark.toString());
                    log(value.toString());
                    if (indexBookmark != -1) {
                      mList[indexBookmark] =
                          mList[indexBookmark].copyWith(isBookmark: value);
                      setState(() {});
                    }
                  },
                  onFollowed: (id, value) {
                    final indexFollow =
                        mList.indexWhere((item) => item.postId == id);
                    log(indexFollow.toString());
                    log(value.toString());
                    if (indexFollow != -1) {
                      mList[indexFollow] =
                          mList[indexFollow].copyWith(isFollowed: value);
                      setState(() {});
                    }
                  },
                  onPinned: (id, value) {
                    final indexPin =
                        mList.indexWhere((item) => item.postId == id);
                    if (indexPin != -1) {
                      mList[indexPin] =
                          mList[indexPin].copyWith(isPinned: value);
                      setState(() {});
                    }
                  },
                  canPin: () {
                    final int pinnedCount =
                        mList.where((item) => item.isPinned == true).length;

                    return pinnedCount < 3;
                  },
                );
              },
            ),
    );
  }

  void callApiForYou(Function(List<Data>) onCompletion, bool refresh) {
    // isLoading = true;
    if (refresh) {
      mList = [];
      pageIndex = 1;
    }

    shortVideoRepo
        .getPostList(
            paginationLimit.toString(), '1505', UrlRes.related, pageIndex)
        .then(
      (value) {
        isLoading = false;

        pageIndex++;
        if (value.isNotEmpty) {
          final newData = value.toList();

          mList = [...mList, ...newData];
          onCompletion(mList);
          shortVideoRepo.cacheVideo(newData.last.postVideo ?? '');
          shortVideoRepo.writeVideo(newData.last);
        }

        // if (!init) {
        setState(() {});
        // }
      },
    );
  }

  void loadCacheVideo() {
    shortVideoRepo.readVideo().then(
      (value) {
        if (value != null) {
          mList.add(value);
          initVideoPlayer();
        }
        callApiForYou(
          (p0) async {
            await _initializeControllerAtIndex(1);
          },
          false,
        );
        // if (!init) {
        //   setState(() {});
        // }
      },
    );
  }

  Future<void> pausePlayer() async {
    await controllers[focusedIndex]?.pause();
  }

  void _playNext(int index) {
    controllers.forEach((key, value) {
      if (value.value.isPlaying) {
        value.pause();
      }
    });

    /// Stop [index - 1] controller
    _stopControllerAtIndex(index - 1);

    /// Dispose [index - 2] controller
    _disposeControllerAtIndex(index - 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index + 1] controller

    _initializeControllerAtIndex(index + 1);
  }

  void _playPrevious(int index) {
    controllers.forEach((key, value) {
      value.pause();
    });

    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    _initializeControllerAtIndex(index - 1);
  }

  Future _initializeControllerAtIndex(int index) async {
    if (mList.length > index && index >= 0) {
      log('🚀🚀🚀 INITIALIZED $index');
      if (index == mList.length - 3) {
        callApiForYou(
          (p0) {},
          false,
        );
      }

      final VideoPlayerController controller = index == 0
          ? VideoPlayerController.file(File(mList[index].postVideo ?? ''))
          : VideoPlayerController.networkUrl(
              Uri.parse(mList[index].postVideo ?? ''));

      /// Add to [controllers] list
      controllers[index] = controller;

      await controller.initialize();
      if (mounted) {
        /// Initialize
        setState(() {});
      }
    }
  }

  void _playControllerAtIndex(int index) {
    focusedIndex = index;
    if (mList.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController? controller = controllers[index];

      if (controller != null) {
        /// Play controller
        controller.play();
        controller.setLooping(true);
        log('🚀🚀🚀 PLAYING $index');
        // ApiService().increasePostViewCount(mList[index].postId.toString());
        setState(() {});
      }
    }
  }

  void _stopControllerAtIndex(int index) {
    if (mList.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController? controller = controllers[index];

      if (controller != null) {
        /// Pause
        controller.pause();

        /// Reset postiton to beginning
        controller.seekTo(const Duration());
        log('==================================');
        log('🚀🚀🚀 STOPPED $index');
      }
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (mList.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController? controller = controllers[index];

      /// Dispose controller
      controller?.dispose();

      if (controller != null) {
        controllers.remove(controller);
      }

      log('🚀🚀🚀 DISPOSED $index');
    }
  }

  Future<void> initVideoPlayer() async {
    /// Initialize 1st video
    await _initializeControllerAtIndex(0);

    /// Play 1st video
    _playControllerAtIndex(0);

    // /// Initialize 2nd vide
    // await _initializeControllerAtIndex(1);
  }

  void onPageChanged(int value) {
    if (value == mList.length - 3) {
      // if (!isLoading) {
      //   callApiForYou(
      //     (p0) {},

      //   );
      // }
    }
    if (value > focusedIndex) {
      _playNext(value);
    } else {
      _playPrevious(value);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
    controllers.forEach((key, value) async {
      await value.dispose();
    });
  }
}
