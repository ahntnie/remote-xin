import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/all.dart';
import '../../../../../core/enums/item_video_from_page_enums.dart';
import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../api/api_service.dart';
import '../../modal/user_video/user_video.dart';
import '../../utils/key_res.dart';
import '../../utils/session_manager.dart';
import 'item_video.dart';

class VideoListScreen extends StatefulWidget {
  final List<Data> list;
  final int index;
  final int? type;
  final int? userId;
  final String? soundId;
  final String? hashTag;
  final String? keyWord;
  final Function(int index, bool isLiked, int count) onLike;
  final Function(int index, int count) onComment;
  final Function(int postId)? onDelete;
  final Function(int index, bool value) onPinned;
  final Function(int index, bool value) onBookmark;
  final Function(int index, bool value) onFollowed;
  final ItemVideoFromPageEnum fromPage;

  const VideoListScreen({
    required this.list,
    required this.index,
    required this.type,
    required this.onDelete,
    required this.fromPage,
    required this.onLike,
    required this.onComment,
    required this.onPinned,
    required this.onBookmark,
    required this.onFollowed,
    super.key,
    this.userId,
    this.soundId,
    this.hashTag,
    this.keyWord,
  });

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<Data> mList = [];
  PageController _pageController = PageController();
  int startingPositionIndex = 0;
  int position = 0;

  final TextEditingController _commentController = TextEditingController();
  SessionManager sessionManager = SessionManager();
  bool isLogin = false;

  int focusedIndex = 0;
  Map<int, VideoPlayerController> controllers = {};
  bool isLoading = false;

  FocusNode commentFocusNode = FocusNode();

  @override
  void initState() {
    // prefData();
    mList = widget.list.toList();

    _pageController = PageController(initialPage: widget.index);
    startingPositionIndex = widget.list.length;
    position = widget.index;
    initVideoPlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: onPageChanged,
                  scrollDirection: Axis.vertical,
                  itemCount: mList.length,
                  itemBuilder: (context, index) {
                    return ItemVideo(
                      type: widget.fromPage,
                      videoData: mList[index],
                      videoPlayerController: controllers[index],
                      onComment: (id, count) {
                        final indexComment =
                            mList.indexWhere((item) => item.postId == id);
                        mList[indexComment] = mList[indexComment]
                            .copyWith(postCommentsCount: count);
                        widget.onComment(indexComment, count);
                      },
                      onLike: (id, liked, count) {
                        final indexLike =
                            mList.indexWhere((item) => item.postId == id);
                        if (liked) {
                          mList[indexLike] = mList[indexLike].copyWith(
                              videoLikesOrNot: 1, postLikesCount: count);
                        } else {
                          mList[indexLike] = mList[indexLike].copyWith(
                            videoLikesOrNot: 0,
                            postLikesCount: count,
                          );
                        }
                        widget.onLike(indexLike, liked, count);
                      },
                      onBookmark: (id, value) {
                        final indexBookmark =
                            mList.indexWhere((item) => item.postId == id);
                        log(indexBookmark.toString());
                        if (indexBookmark != -1) {
                          widget.onBookmark(indexBookmark, value);
                          mList[indexBookmark] =
                              mList[indexBookmark].copyWith(isBookmark: value);
                        }
                      },
                      onFollowed: (id, value) {
                        final indexFollow =
                            mList.indexWhere((item) => item.postId == id);
                        log(indexFollow.toString());
                        if (indexFollow != -1) {
                          widget.onFollowed(indexFollow, value);
                          mList[indexFollow] =
                              mList[indexFollow].copyWith(isFollowed: value);
                        }
                      },
                      onPinned: (id, value) {
                        final indexPin =
                            mList.indexWhere((item) => item.postId == id);
                        log(indexPin.toString());
                        if (indexPin != -1) {
                          widget.onPinned(indexPin, value);
                          mList[indexPin] =
                              mList[indexPin].copyWith(isPinned: value);
                        }
                      },
                      canPin: () {
                        final int pinnedCount =
                            mList.where((item) => item.isPinned == true).length;

                        return pinnedCount < 3;
                      },
                      onDelete: (postId) {
                        final indexDelete =
                            mList.indexWhere((item) => item.postId == postId);
                        if (indexDelete != -1) {
                          // _pageController.animateToPage(index + 1,
                          //     duration: const Duration(milliseconds: 500),
                          //     curve: Curves.easeInToLinear);
                          // _playNext(index + 1);

                          // controllers.remove(index);

                          // mList.removeAt(index);
                          // log(index.toString());
                          ViewUtil.showAppCupertinoAlertDialog(
                            title: '${context.l10n.button__delete} video',
                            message: context.l10n.delete_video_confirm,
                            negativeText: context.l10n.button__cancel,
                            positiveText: context.l10n.button__confirm,
                            onPositivePressed: () async {
                              Get.close(2);
                              if (widget.onDelete != null) {
                                widget.onDelete!(index);
                              }
                              await Get.find<ShortVideoRepository>()
                                  .deleteShortVideo(
                                      mList[indexDelete].postId ?? 0);
                            },
                          );

                          // Get.back();

                          // setState(() {});
                        }
                      },
                    );
                  },
                ),
              ),
              //     SafeArea(
              //       top: false,
              //       child: Container(
              //         margin:
              //             const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              //         child: Row(
              //           children: [
              //             Expanded(
              //               child: TextField(
              //                   controller: _commentController,
              //                   focusNode: commentFocusNode,
              //                   decoration: InputDecoration(
              //                       border: InputBorder.none,
              //                       hintText: LKey.leaveYourComment.tr,
              //                       hintStyle: const TextStyle(
              //                           fontFamily: FontRes.fNSfUiRegular),
              //                       contentPadding:
              //                           const EdgeInsets.symmetric(horizontal: 10)),
              //                   cursorColor: ColorRes.colorTextLight),
              //             ),
              //             ClipOval(
              //               child: InkWell(
              //                 onTap: () {
              //                   if (_commentController.text.trim().isEmpty) {
              //                     CommonUI.showToast(
              //                         msg: LKey.enterCommentFirst.tr);
              //                   } else {
              //                     if (SessionManager.userId == -1 || !isLogin) {
              //                       showModalBottomSheet(
              //                         backgroundColor: Colors.transparent,
              //                         shape: const RoundedRectangleBorder(
              //                           borderRadius: BorderRadius.vertical(
              //                               top: Radius.circular(20)),
              //                         ),
              //                         isScrollControlled: true,
              //                         context: context,
              //                         builder: (context) {
              //                           return LoginSheet();
              //                         },
              //                       );
              //                       return;
              //                     }

              //                     ApiService()
              //                         .addComment(_commentController.text.trim(),
              //                             '${mList[position].postId}')
              //                         .then(
              //                       (value) {
              //                         _commentController.clear();
              //                         commentFocusNode.unfocus();
              //                         mList[position].setPostCommentCount(true);
              //                         setState(() {});
              //                       },
              //                     );
              //                   }
              //                 },
              //                 child: Container(
              //                   height: 35,
              //                   width: 35,
              //                   decoration: const BoxDecoration(
              //                     gradient: LinearGradient(colors: [
              //                       ColorRes.colorTheme,
              //                       ColorRes.colorPink
              //                     ]),
              //                   ),
              //                   child: const Icon(Icons.send_rounded,
              //                       color: ColorRes.white, size: 16),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
            ],
          ),
          SafeArea(
              bottom: false,
              child: AppIcon(
                icon: Assets.icons.arrowLeft,
                color: Colors.white,
                onTap: () => Get.back(),
              ).paddingOnly(left: 20, top: 20)),
        ],
      ),
    );
  }

  void callApiForYou(Function(List<Data>) onCompletion) {
    // ApiService()
    //     .getPostsByType(
    //   pageDataType: widget.type,
    //   userId: widget.userId,
    //   soundId: widget.soundId,
    //   hashTag: widget.hashTag,
    //   keyWord: widget.keyWord,
    //   start: startingPositionIndex.toString(),
    //   limit: paginationLimit.toString(),
    // )
    //     .then(
    //   (value) {
    //     if (value.data != null && value.data!.isNotEmpty) {
    //       if (mList.isEmpty) {
    //         mList = value.data ?? [];
    //         setState(() {});
    //       } else {
    //         mList.addAll(value.data ?? []);
    //       }
    //       startingPositionIndex += paginationLimit;
    //     }
    //   },
    // );
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
      /// Create new controller
      final VideoPlayerController controller = VideoPlayerController.networkUrl(
          Uri.parse(mList[index].postVideo ?? ''));

      /// Add to [controllers] list
      controllers[index] = controller;

      /// Initialize
      await controller.initialize().then((value) {
        setState(() {});
      });

      log('🚀🚀🚀 INITIALIZED $index');
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
        ApiService().increasePostViewCount(mList[index].postId.toString());
        log('🚀🚀🚀 PLAYING $index');
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

        /// Reset position to beginning
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
    await _initializeControllerAtIndex(position);

    /// Play 1st video
    _playControllerAtIndex(position);

    /// Initialize 2nd vide
    if (position >= 0) {
      await _initializeControllerAtIndex(position - 1);
    }
    await _initializeControllerAtIndex(position + 1);
  }

  void onPageChanged(int value) {
    if (value == mList.length - 3) {
      if (!isLoading) {
        callApiForYou(
          (p0) {},
        );
      }
    }
    if (value > focusedIndex) {
      _playNext(value);
    } else {
      _playPrevious(value);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controllers.forEach((key, value) async {
        await value.dispose();
      });
    });
    _pageController.dispose();
  }

  Future<void> prefData() async {
    await sessionManager.initPref();
    isLogin = sessionManager.getBool(KeyRes.login) ?? false;
    setState(() {});
  }
}
