import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../core/all.dart';
import '../../../../../core/enums/item_video_from_page_enums.dart';
import '../../../../../repositories/all.dart';
import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../common_controller.dart/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/gen/assets.gen.dart';
import '../../../../resource/styles/styles.dart';
import '../../../../routing/routing.dart';
import '../../../all.dart';
import '../../modal/user_video/user_video.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/session_manager.dart';
import '../comment/comment_screen.dart';
import '../report/report_screen.dart';
import 'widget/bottom_sheet_action_short.dart';
import 'widget/share_sheet.dart';

class LottieAnimation {
  final AnimationController controller;
  final Offset position;

  LottieAnimation({
    required this.controller,
    required this.position,
  });
}

// ignore: must_be_immutable
class ItemVideo extends StatefulWidget {
  final Data? videoData;
  ItemVideoState? item;
  final VideoPlayerController? videoPlayerController;
  final Function(int id, bool isLiked, int count) onLike;
  final Function(int id, int count) onComment;
  final Function(int postId)? onDelete;
  final Function(int id, bool value) onPinned;
  final Function(int id, bool value) onBookmark;
  final Function(int id, bool value) onFollowed;
  final bool Function() canPin;
  final ItemVideoFromPageEnum type;

  ItemVideo({
    required this.onLike,
    required this.onComment,
    required this.onDelete,
    required this.onPinned,
    required this.canPin,
    required this.type,
    required this.onBookmark,
    required this.onFollowed,
    super.key,
    this.videoData,
    this.videoPlayerController,
  });

  @override
  ItemVideoState createState() => ItemVideoState();
}

class ItemVideoState extends State<ItemVideo> with TickerProviderStateMixin {
  final ChatDashboardController _chatDashboardController = Get.find();

  bool isLogin = false;
  SessionManager sessionManager = SessionManager();
  bool isLike = false;
  int likeCount = 0;
  int commentCount = 0;
  int shareCount = 0;
  bool isLoading = false;
  final shortVideoRepo = Get.find<ShortVideoRepository>();
  final appController = Get.find<AppController>();
  final List<LottieAnimation> _animations = [];

  bool isShowHeart = false;
  DateTime? _lastTapTime;
  Timer? _heartResetTimer;
  bool isBookMark = false;
  bool isPinned = false;
  bool isFollow = false;

  @override
  void initState() {
    if (widget.videoData != null) {
      isLike = widget.videoData!.videoLikesOrNot == 0 ? false : true;
      likeCount = widget.videoData!.postLikesCount ?? 0;
      commentCount = widget.videoData!.postCommentsCount ?? 0;
      shareCount = widget.videoData!.postShareCount ?? 0;
      isPinned = widget.videoData!.isPinned ?? false;
      isBookMark = widget.videoData!.isBookmark ?? false;
      isFollow = widget.videoData!.isFollowed ?? false;
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ItemVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the data has changed
    if (oldWidget.videoData != widget.videoData) {
      setState(() {
        isPinned = widget.videoData?.isPinned ?? false;
      });
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _heartResetTimer?.cancel();
    await widget.videoPlayerController?.pause();
  }

  void _handleDoubleTap(TapDownDetails details) {
    _showLottieAnimation(details);
    isShowHeart = true;
  }

  void _showLottieAnimation(TapDownDetails details) {
    // Create animation controller
    final controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Add new animation to list
    setState(() {
      _animations.add(
        LottieAnimation(
          controller: controller,
          position: details.localPosition,
        ),
      );
    });

    // Play animation and remove it when done
    controller.forward().then((_) {
      setState(() {
        _animations
            .removeWhere((animation) => animation.controller == controller);
      });
      controller.dispose();
    });
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      backgroundColor: AppColors.white,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${context.l10n.newsfeed__share}',
              style: const TextStyle(
                  color: AppColors.text2,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
            Obx(() => Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _chatDashboardController.conversations.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 50,
                        child: Column(
                          children: <Widget>[
                            AppCircleAvatar(
                                url: _chatDashboardController
                                        .conversations[index].avatarUrl ??
                                    ''),
                            Text(
                              _chatDashboardController.conversations[index]
                                  .chatPartner()!
                                  .displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                )),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBoxFit = ((widget.videoPlayerController?.value.size.height ?? 0) /
            (widget.videoPlayerController?.value.size.width ?? 0)) >=
        (0.8.sh / 1.sw);
    final boxFit = isBoxFit ? BoxFit.cover : BoxFit.fitWidth;
    log('boxFit: $boxFit');
    final bool isLandscape =
        (widget.videoPlayerController?.value.size.width ?? 0) >
                ((widget.videoPlayerController?.value.size.height ?? 0) * 2) &&
            (isBoxFit == false);
    return Stack(
      children: [
        GestureDetector(
          // onLongPress: _onLongPress,
          // onTap: _onTap,
          onDoubleTapDown: _handleDoubleTap,
          onTapDown: _onTap,
          onDoubleTap: () {
            if (!isLike) {
              setState(() {
                isLike = true;
                likeCount = likeCount + 1;
              });
              widget.onLike(widget.videoData!.postId ?? 0, true, likeCount);
              shortVideoRepo.likeOrUnlikeVideo(widget.videoData!.postId ?? 0);
            }
          },

          child: VisibilityDetector(
            onVisibilityChanged: (VisibilityInfo info) {
              final visiblePercentage = info.visibleFraction * 100;
              if (visiblePercentage > 50) {
                widget.videoPlayerController?.play();
                if (mounted) {
                  setState(() {});
                }
              } else {
                widget.videoPlayerController?.pause();
                if (mounted) {
                  setState(() {});
                }
              }
            },
            key: Key(
                'ke1${ConstRes.itemBaseUrl}${widget.videoData!.postVideo!}'),
            child: RotatedBox(
              quarterTurns: isLandscape ? 1 : 0,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: boxFit,
                  child: SizedBox(
                    width: widget.videoPlayerController!.value.size.width ?? 0,
                    height: boxFit == BoxFit.fitWidth
                        ? widget.videoPlayerController!.value.size.height *
                            ((widget.videoPlayerController!.value.size.height *
                                    0.09) /
                                100)
                        : widget.videoPlayerController!.value.size.height,
                    child: widget.videoPlayerController != null
                        ? VideoPlayer(widget.videoPlayerController!)
                        : const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          // onLongPress: _onLongPress,
          // onTap: _onTap,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              width: double.infinity,
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.2, 0.6, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppCircleAvatar(
                    url: widget.videoData!.userProfile ?? '',
                    size: 34,
                  ),
                  AppSpacing.gapW8,
                  Text(
                    '${widget.videoData?.fullName}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppTextStyles.s16w700,
                  ),
                  AppSpacing.gapW12,
                  if (appController.lastLoggedUser?.id !=
                      widget.videoData?.userId)
                    OutlinedButton(
                      onPressed: () async {
                        setState(() {
                          isFollow = !isFollow;
                        });
                        widget.onFollowed(widget.videoData?.postId ?? 0,
                            !(widget.videoData?.isFollowed ?? false));
                        final res = await shortVideoRepo
                            .followUser(widget.videoData!.userId ?? 0);
                        if (res.status == 200) {
                          if (res.message ==
                              "You are now following this user") {
                            ViewUtil.showToast(
                              title: context.l10n.global__success_title,
                              message: context.l10n.follow_successfully,
                              // backgroundColor: AppColors.negative,
                            );
                          } else if (res.message ==
                              "Successfully unfollowed this user") {
                            ViewUtil.showToast(
                              title: context.l10n.global__success_title,
                              message: context.l10n.unfollow_successfully,
                              // backgroundColor: AppColors.negative,
                            );
                          }
                        } else {
                          ViewUtil.showToast(
                            title: context.l10n.global__error_title,
                            message: context.l10n.global__error_has_occurred,
                            // backgroundColor: AppColors.negative,
                          );
                          setState(() {
                            isPinned = !isPinned;
                          });
                          log('5675675675675');
                          widget.onFollowed(widget.videoData?.postId ?? 0,
                              !(widget.videoData?.isFollowed ?? false));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        side:
                            const BorderSide(color: Colors.white54, width: 0.4),
                      ),
                      child: Text(
                        isFollow ? context.l10n.unfollow : context.l10n.follow,
                        style: AppTextStyles.s14w700
                            .copyWith(color: AppColors.white),
                      ),
                    )
                ],
              ).clickable(() async {
                final UserRepository userRepository = Get.find();
                final ContactRepository contactRepository = Get.find();
                final AppController appController = Get.find();
                final userPartner = await userRepository
                    .getUserById(widget.videoData?.userId ?? 0);
                final resultContactList =
                    await contactRepository.checkContactExist(
                  phoneNumber: userPartner.phone ?? '',
                  userId: appController.lastLoggedUser!.id,
                );
                Get.toNamed(Routes.myProfile, arguments: {
                  'isMine': false,
                  'user': userPartner,
                  'isAddContact': resultContactList.isEmpty,
                });
              }),
              AppSpacing.gapH8,
              widget.videoData?.postDescription != null
                  ? Container(
                      constraints: BoxConstraints(maxWidth: 0.8.sw),
                      margin: const EdgeInsets.only(bottom: 5, top: 4),
                      child: DetectableText(
                        text:
                            "${widget.videoData?.postHashTag ?? ''} ${widget.videoData?.postDescription ?? ''}",
                        // maxLines: 3,
                        // overflow: TextOverflow.ellipsis,
                        detectedStyle:
                            AppTextStyles.s12w500.copyWith(fontSize: 13),
                        basicStyle:
                            AppTextStyles.s12w500.copyWith(fontSize: 13),
                        onTap: (text) {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         VideosByHashTagScreen(text),
                          //   ),
                          // );
                          log(text);
                        },
                        detectionRegExp: detectionRegExp()!,
                      ),
                    )
                  : const SizedBox(),
              // Text(
              //   widget.videoData?.soundTitle ?? '',
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: const TextStyle(
              //     fontFamily: FontRes.fNSfUiMedium,
              //     letterSpacing: 0.7,
              //     fontSize: 13,
              //     color: ColorRes.white,
              //   ),
              // ),
              AppSpacing.gapH4,
              widget.videoData != null && widget.videoData?.soundId == 1
                  ? const SizedBox()
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: const Color(0xff606060).withOpacity(0.5),
                              shape: BoxShape.circle),
                          child: AppIcon(
                            icon: Assets.icons.soundShort,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                        AppSpacing.gapW4,
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: const Color(0xff606060).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(100)),
                          child: Row(
                            children: [
                              AppSpacing.gapW4,
                              AppIcon(
                                icon: Assets.icons.musicShort,
                                color: Colors.white,
                                size: 15,
                              ),
                              AppSpacing.gapW8,
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: (widget
                                              .videoData?.soundTitle?.length
                                              .toDouble() ??
                                          0) *
                                      7.5,
                                ),
                                height: 20,
                                child: Marquee(
                                  text: widget.videoData?.soundTitle ?? '',
                                  style: AppTextStyles.s12w500,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 50.0,
                                  pauseAfterRound: const Duration(seconds: 3),
                                  startAfter: const Duration(
                                    seconds: 4,
                                  ),
                                  // Add this to control when scrolling starts
                                  accelerationCurve: Curves.linear,
                                  // decelerationDuration:
                                  //     const Duration(milliseconds: 2000),
                                  // accelerationDuration:
                                  //     const Duration(milliseconds: 1000),
                                  decelerationCurve: Curves.easeOut,
                                ),
                              ),
                              AppSpacing.gapW8,
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 20,
          child: Column(
            children: [
              // BouncingWidget(
              //     duration: const Duration(milliseconds: 100),
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) {
              //             return ProfileScreen(
              //                 avatar:
              //                     widget.videoData?.userProfile ?? '',
              //                 nickname:
              //                     widget.videoData?.userName ?? '',
              //                 fullName:
              //                     widget.videoData?.fullName ?? '',
              //                 userId: widget.videoData?.userId ?? 0);
              //           },
              //         ),
              //       );
              //     },
              //     child: AppCircleAvatar(
              //       url: widget.videoData!.userProfile ?? '',
              //       size: 45,
              //     )),
              AppSpacing.gapH20,
              LikeButton(
                animationDuration: const Duration(milliseconds: 500),
                size: 35,
                onTap: (isLiked) {
                  if (isLike) {
                    // widget.videoData?.setVideoLikesOrNot(0);
                    setState(() {
                      isLike = false;
                      likeCount = likeCount - 1;
                    });
                    widget.onLike(
                        widget.videoData!.postId ?? 0, false, likeCount);
                  } else {
                    // widget.videoData?.setVideoLikesOrNot(1);
                    setState(() {
                      isLike = true;
                      likeCount = likeCount + 1;
                    });
                    widget.onLike(
                        widget.videoData!.postId ?? 0, true, likeCount);
                  }
                  shortVideoRepo
                      .likeOrUnlikeVideo(widget.videoData!.postId ?? 0);

                  return Future.value(isLike);
                },
                likeBuilder: (isLiked) {
                  return isLike
                      ? AppIcon(
                          icon: Assets.icons.heartFillShort,
                          color: const Color(0xffD7443E),
                          size: 35,
                        )
                      : AppIcon(
                          icon: Assets.icons.heartOutlineShort,
                          color: Colors.white,
                          size: 35,
                        );
                },
              ),
              Text(
                NumberFormat.compact(locale: 'en').format(likeCount),
                style: const TextStyle(
                    color: ColorRes.white, fontFamily: FontRes.fNSfUiSemiBold),
              ),
              AppSpacing.gapH20,
              InkWell(
                onTap: () {
                  Get.bottomSheet(
                    CommentScreen(widget.videoData, (type) {
                      if (type == 0) {
                        setState(() {
                          commentCount = commentCount + 1;
                        });
                        widget.onComment(
                            widget.videoData!.postId ?? 0, commentCount);
                      } else {
                        setState(() {
                          commentCount = commentCount - 1;
                        });
                        widget.onComment(
                            widget.videoData!.postId ?? 0, commentCount);
                      }
                    }),
                    isScrollControlled: true,
                  );
                },
                child: AppIcon(
                  icon: Assets.icons.commentShort,
                  size: 35,
                ),
              ),
              Text(NumberFormat.compact(locale: 'en').format(commentCount),
                  style: const TextStyle(color: ColorRes.white)),
              AppSpacing.gapH20,
              AppIcon(
                icon: isBookMark
                    ? Assets.icons.bookmarkFill
                    : Assets.icons.bookmarkOutline,
                size: 32,
                color: AppColors.white,
                onTap: () async {
                  setState(() {
                    isBookMark = !isBookMark;
                  });
                  widget.onBookmark(widget.videoData?.postId ?? 0,
                      !(widget.videoData?.isBookmark ?? false));

                  final res = await shortVideoRepo
                      .bookmarkOrUnBookmark(widget.videoData!.postId ?? 0);
                  if (res.status == 200) {
                    if (res.message == "Video bookmarked successfully") {
                      ViewUtil.showToast(
                        title: context.l10n.global__success_title,
                        message: context.l10n.bookmark_successfully,
                        // backgroundColor: AppColors.negative,
                      );
                    } else {
                      ViewUtil.showToast(
                        title: context.l10n.global__success_title,
                        message: context.l10n.unbookmark_successfully,
                        // backgroundColor: AppColors.negative,
                      );
                    }
                  } else {
                    ViewUtil.showToast(
                      title: context.l10n.global__error_title,
                      message: context.l10n.global__error_has_occurred,
                      // backgroundColor: AppColors.negative,
                    );
                    setState(() {
                      isPinned = !isPinned;
                    });
                    log('5675675675675');
                    widget.onBookmark(widget.videoData?.postId ?? 0,
                        !(widget.videoData?.isBookmark ?? false));
                  }
                },
              ),
              AppSpacing.gapH20,
              InkWell(
                  onTap: () async {
                    // shareLink(widget.videoData!);
                    setState(() {
                      isLoading = true;
                    });
                    final link = await shortVideoRepo
                        .getShareLink('reels/${widget.videoData!.postId}');
                    setState(() {
                      isLoading = false;
                    });

                    _showShareBottomSheet();
                    // Share.share(link, subject: 'XINTEL');
                  },
                  child: AppIcon(
                    icon: Assets.icons.shareShort,
                    size: 35,
                  )),
              Text(NumberFormat.compact(locale: 'en').format(shareCount),
                  style: const TextStyle(
                    color: ColorRes.white,
                  )),
              AppSpacing.gapH20,
              AppIcon(
                icon: Assets.icons.moreShort,
                color: Colors.white,
                size: 35,
                onTap: () => BottomSheetActionShort.showBottomSheetAction(
                    context: context,
                    onSaved: () {},
                    onPin: () async {
                      Navigator.of(context).pop();
                      if (widget.type == ItemVideoFromPageEnum.profile) {
                        if (isPinned) {
                          setState(() {
                            isPinned = !isPinned;
                          });
                          widget.onPinned(widget.videoData?.postId ?? 0,
                              !(widget.videoData?.isPinned ?? false));
                        } else {
                          final canPin = widget.canPin.call();
                          if (canPin) {
                            setState(() {
                              isPinned = !isPinned;
                            });
                            log('5675675675675');
                            widget.onPinned(widget.videoData?.postId ?? 0,
                                !(widget.videoData?.isPinned ?? false));
                          }
                        }
                      } else {
                        log('1231231231231');
                        widget.onPinned(widget.videoData?.postId ?? 0,
                            !(widget.videoData?.isPinned ?? false));
                      }
                      final res = await shortVideoRepo
                          .pinOrUnpinVideo(widget.videoData!.postId ?? 0);
                      if (res.status == 200) {
                        if (res.message == "Video pinned successfully") {
                          ViewUtil.showToast(
                            title: context.l10n.global__success_title,
                            message: context.l10n.pin_video_successfully,
                            // backgroundColor: AppColors.negative,
                          );
                        } else {
                          ViewUtil.showToast(
                            title: context.l10n.global__success_title,
                            message: context.l10n.unpin_video_successfully,
                            // backgroundColor: AppColors.negative,
                          );
                        }
                      } else {
                        if (res.message ==
                            "You can pin only 3 videos at a time.") {
                          ViewUtil.showToast(
                            title: context.l10n.global__error_title,
                            message: context.l10n.pin_video_reach_limit,
                            // backgroundColor: AppColors.negative,
                          );
                        } else {
                          ViewUtil.showToast(
                            title: context.l10n.global__error_title,
                            message: res.message,
                            // backgroundColor: AppColors.negative,
                          );
                        }
                        // setState(() {
                        //   isPinned = !isPinned;
                        // });
                        // log('5675675675675');
                        // widget.onPinned(widget.videoData?.postId ?? 0,
                        //     !(widget.videoData?.isPinned ?? false));
                      }
                    },
                    onDownload: () async {
                      // Download video
                      Navigator.of(context).pop();
                      final tempDir = await getTemporaryDirectory();
                      final videoPath =
                          '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}downloaded_short_video.mp4';
                      await Dio().download(
                        widget.videoData?.postVideo ?? '',
                        videoPath,
                        onReceiveProgress: (count, total) {
                          log('$count/$total');
                        },
                      );

                      // Prepare logo
                      final logoBytes =
                          await rootBundle.load('assets/images/logo.png');
                      final logoPath = '${tempDir.path}/logo_xin.png';
                      await File(logoPath)
                          .writeAsBytes(logoBytes.buffer.asUint8List());

                      // Add watermark
                      final outputPath =
                          '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}watermarked_video.mp4';
                      final command = '-i $videoPath -i $logoPath '
                          '-filter_complex "[1]scale=iw*0.2:-1[wm];'
                          '[0][wm]overlay=main_w-overlay_w-10:main_h-overlay_h-10" '
                          '-crf 12 -preset slower -b:v 15M -maxrate 15M -bufsize 30M '
                          '-codec:a copy '
                          '$outputPath';

                      await FFmpegKit.execute(command).then((session) async {
                        await GallerySaver.saveVideo(outputPath).then(
                          (bool? success) {
                            log('asasasasasasasa');
                            if (success != null) {
                              if (success) {
                                ViewUtil.showToast(
                                    title: context.l10n.global__success_title,
                                    message: context.l10n.download_success);
                              } else {
                                ViewUtil.showToast(
                                    title: context.l10n.global__error_title,
                                    message: context.l10n.download_failed);
                              }
                            } else {
                              ViewUtil.showToast(
                                  title: context.l10n.global__error_title,
                                  message: context.l10n.download_failed);
                            }
                          },
                        );
                        // }
                      });
                    },
                    onReport: () {
                      Get.back();
                      Get.toNamed(
                        Routes.report,
                        arguments: ReportArgs(
                          type: ReportType.video,
                          data: widget.videoData?.postId ?? 0,
                        ),
                      )?.then(
                        (isReported) {
                          if (isReported != null && isReported) {
                            // hideMessage(message);

                            // ViewUtil.showAppSnackBarNewFeeds(
                            //   title: Get.context!.l10n.newsfeed__report_success,
                            // );
                            ViewUtil.showToast(
                                title: context.l10n.global__success_title,
                                message:
                                    Get.context!.l10n.newsfeed__report_success);
                          }
                        },
                      );
                    },
                    onDelete: () {
                      widget.onDelete?.call(widget.videoData?.postId ?? 0);
                      // shortVideoRepo
                      //     .deleteShortVideo(widget.videoData?.postId ?? 0);
                      // ViewUtil.showToast(
                      //     title: context.l10n.global__success_title,
                      //     message: 'Video deleted successfully');
                    },
                    isMyVideo: appController.lastLoggedUser?.id ==
                        widget.videoData?.userId,
                    isPinned: isPinned,
                    isSaved: true,
                    isShowDelete: widget.type == ItemVideoFromPageEnum.profile,
                    onEdit: () {
                      Navigator.of(context).pop();
                    }),
              ),
              AppSpacing.gapH20,
              // MusicDisk(widget.videoData),
            ],
          ),
        ),
        widget.videoPlayerController != null &&
                widget.videoPlayerController!.value.isPlaying
            ? const SizedBox()
            : Center(
                child: AppIcon(
                  icon: Assets.icons.playButton,
                  color: Colors.white.withOpacity(0.4),
                  size: 0.15.sw,
                ),
              ),
        isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.blue10,
                ),
              )
            : const SizedBox(),
        ..._animations.map((animation) {
          return Positioned(
            left: animation.position.dx - 0.125.sw, // Center the animation
            top: animation.position.dy - 0.125.sw, // Center the animation
            child: AppIcon(
              icon: Assets.icons.heartFillShort,
              size: 0.25.sw,
              color: const Color(0xffD7443E),
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> shareLink(Data videoData) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SocialLinkShareSheet(videoData: videoData);
      },
    );
  }

  void _onTap(TapDownDetails details) {
    final now = DateTime.now();
    _lastTapTime = now;
    if (isShowHeart) {
      _handleDoubleTap(details);
      _heartResetTimer?.cancel();

      // Start new timer
      _heartResetTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            isShowHeart = false;
          });
        }
      });
    } else {
      if (widget.videoPlayerController != null &&
          widget.videoPlayerController!.value.isPlaying) {
        widget.videoPlayerController?.pause();
        setState(() {});
      } else {
        widget.videoPlayerController?.play();
        setState(() {});
      }
    }
  }

  void _onLongPress() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ReportScreen(1, widget.videoData!.postId.toString());
        },
        isScrollControlled: true,
        backgroundColor: Colors.transparent);
  }
}
