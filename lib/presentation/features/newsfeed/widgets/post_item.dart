import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../../../routing/routers/app_pages.dart';
import '../comments/controllers/comment_input_controller.dart';
import '../posts/widgets/heart_animation_widget.dart';
import 'image_detail.dart';

class PostItem extends StatefulWidget {
  final Post post;
  final User currentUser;
  final Function(Post post) onLike;
  final Function(Post post) onUnLike;
  final Function(Post post)? onDelete;
  final Function(Post post)? onEdit;
  final Function(Post post)? onReport;
  final Function(Post post)? onShare;
  final Function(User user)? onGoToPersonal;
  final bool isShowComment;
  final bool isPostInHome;
  final bool isPostDetail;

  const PostItem({
    required this.post,
    required this.currentUser,
    required this.onLike,
    required this.onUnLike,
    this.onDelete,
    this.onEdit,
    this.onReport,
    this.onShare,
    this.onGoToPersonal,
    super.key,
    this.isShowComment = false,
    this.isPostInHome = true,
    this.isPostDetail = false,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool isAnimating = false;
  Offset position = Offset.zero;

  @override
  void initState() {
    super.initState();
    // _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isShowComment) {
        _onTapComment();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _buildItemPost(context, widget.post));
  }

  Widget _buildItemPost(BuildContext context, Post post) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.postDetail,
          arguments: {
            'postId': post.id,
            'isPostInHome': widget.isPostInHome,
          },
        );
      },
      onDoubleTap: () {
        if (post.userReaction == null) {
          widget.onLike(post);
        }
        setState(() {
          isAnimating = true;
        });
      },
      onDoubleTapDown: (details) {
        setState(() {
          position = details.localPosition;
          isAnimating = true;
        });
      },
      child: Container(
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isPostDetail == false)
                  _buildHeaderPost(context, post: post),
                if ((post.content ?? '').isNotEmpty)
                  GestureDetector(
                    onLongPress: () {
                      _showCopyContent(post.content ?? '', context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: Sizes.s20,
                        right: Sizes.s20,
                      ),
                      child: ExpandableText(
                        (post.content ?? '').trim(),
                        expandText: context.l10n.global__show_more_label,
                        collapseText: context.l10n.global__show_less_label,
                        maxLines: 4,
                        textAlign: TextAlign.left,
                        style: AppTextStyles.s16w400
                            .copyWith(color: AppColors.text2),
                        linkColor: AppColors.zambezi,
                        onUrlTap: (url) {
                          IntentUtils.openBrowserURL(url: url);
                        },
                        urlStyle: AppTextStyles.s12w500.text4Color,
                        expanded: widget.isPostDetail,
                      ),
                      // Text(
                      //   (post.content ?? '').trim(),
                      //   style: AppTextStyles.s14w500,
                      //   textAlign: TextAlign.left,
                      // ),
                    ),
                  ),
                if ((post.content ?? '').isNotEmpty &&
                    post.attachments.isNotEmpty)
                  AppSpacing.gapH8,
                _buildListImageOrVideo(post.attachments, post),
                // case share post
                if (post.originalPost != null && post.isShare)
                  _buildOriginalPost(
                    originalPost: post.originalPost!,
                    postParent: post,
                    context: context,
                  ),
                // case share post is deleted
                if (post.originalPost == null && post.isShare)
                  _buildSharePostToDelete(context: context),
                _buildAction(context, post: post, isDetail: false)
                    .paddingOnly(top: 4),
              ],
            ).paddingOnly(bottom: !widget.isPostDetail ? Sizes.s8 : 0),
            Positioned(
              left: position.dx - 30,
              top: position.dy - 30,
              child: Opacity(
                opacity: isAnimating ? 1 : 0,
                child: HeartAnimationWiget(
                    isAnimating: isAnimating,
                    onEnd: () {
                      setState(() {
                        isAnimating = false;
                      });
                    },
                    child: Assets.images.likeAnimation
                        .image(height: 60, width: 60, fit: BoxFit.cover)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderPost(BuildContext context, {required Post post}) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCircleAvatar(
              size: 52,
              url: post.author.avatarPath ?? '',
            ).clickable(() {
              widget.onGoToPersonal?.call(post.author);
            }),
            AppSpacing.gapW12,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author.fullName,
                  style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
                ).clickable(() {
                  widget.onGoToPersonal?.call(post.author);
                }),
                const SizedBox(
                  height: 6,
                ),
                Row(
                  children: [
                    Text(
                      DateTimeUtil.timeAgo(context, post.createdAt),
                      style: AppTextStyles.s12w500.toColor(AppColors.zambezi),
                    ),
                    AppSpacing.gapW4,
                    AppIcon(
                      icon: AppIcons.public,
                      color: AppColors.zambezi,
                      size: 16,
                    )
                  ],
                ),
              ],
            ),
            const Expanded(
              child: SizedBox(),
            ),
          ],
        ).paddingOnly(
          left: Sizes.s20,
          right: Sizes.s20,
          top: Sizes.s16,
          bottom: Sizes.s8,
        ),
        Positioned(
          right: 0,
          top: 16,
          child: Container(
            // color: Colors.amber,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: AppIcon(
              icon: Assets.icons.postOption,
              color: AppColors.text2,
              size: 6,
              onTap: () {
                _buildShowBottomSheetMore(post, context: context);
              },
            ),
          ).clickable(() {
            _buildShowBottomSheetMore(post, context: context);
          }),
        ),
      ],
    );
  }

  Widget _buildAction(BuildContext context,
      {required Post post, required bool isDetail}) {
    return Column(
      children: [
        if (widget.isPostDetail == false)
          Row(
            children: [
              Text(
                context.l10n.newsfeed__like_count(
                  NumberFormatConstants.formatNumber(post.likeCount),
                ),
                style: AppTextStyles.s14w400
                    .toColor(isDetail ? AppColors.subText2 : AppColors.zambezi),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              Text(
                context.l10n.newsfeed__comment_count(
                  NumberFormatConstants.formatNumber(post.commentCount),
                ),
                style: AppTextStyles.s14w400
                    .toColor(isDetail ? AppColors.subText2 : AppColors.zambezi),
              ).clickable(() {
                _onTapComment();
              }),
              AppSpacing.gapW12,
              Text(
                context.l10n.newsfeed__share_count(
                  NumberFormatConstants.formatNumber(post.shareCount),
                ),
                style: AppTextStyles.s14w400
                    .toColor(isDetail ? AppColors.subText2 : AppColors.zambezi),
              ),
            ],
          ),
        if (widget.isPostDetail == false) AppSpacing.gapH8,
        if (isDetail)
          const Divider(
            height: 1,
            color: AppColors.subText2,
          ),
        if (isDetail) AppSpacing.gapH8,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(
              title: context.l10n.newsfeed__like,
              isDetail: isDetail,
              icon:
                  post.userReaction == null ? AppIcons.react : AppIcons.reacted,
              color: post.userReaction == null
                  ? AppColors.subText2
                  : AppColors.reacted,
              onTap: () {
                if (post.userReaction == null) {
                  HapticFeedback.lightImpact();
                  widget.onLike(post);
                } else {
                  widget.onUnLike(post);
                }
              },
            ),
            _buildActionItem(
              title: context.l10n.newsfeed__comment,
              icon: AppIcons.comment,
              isDetail: isDetail,
              onTap: () {
                if (widget.isPostDetail) {
                  Get.find<CommentInputController>().focusNode.requestFocus();
                } else {
                  _onTapComment(autoFocus: true);
                }
              },
            ),
            _buildActionItem(
              title: context.l10n.newsfeed__share,
              icon: AppIcons.share,
              isDetail: isDetail,
              onTap: () => widget.onShare?.call(post),
            ),
          ],
        ),
        if (widget.isPostDetail) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.gapH8,
              if (post.likeCount != 0)
                Row(
                  children: [
                    AppIcon(
                      icon: AppIcons.reacted,
                      size: 16,
                    ),
                    AppSpacing.gapW8,
                    Text(
                      context.l10n.newsfeed__like_count(
                        NumberFormatConstants.formatNumber(post.likeCount),
                      ),
                      style: AppTextStyles.s16w700.toColor(AppColors.text2),
                    ),
                  ],
                ),
              if (post.shareCount != 0) ...[
                AppSpacing.gapH8,
                Text(
                  context.l10n.newsfeed__share_count(
                    NumberFormatConstants.formatNumber(post.shareCount),
                  ),
                  style: AppTextStyles.s14w600.toColor(AppColors.text2),
                ),
              ],
            ],
          ),
        ],
      ],
    ).paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s12);
  }

  Widget _buildActionItem({
    required String title,
    required Object icon,
    required Function onTap,
    required bool isDetail,
    Color? color,
  }) {
    return Row(
      children: [
        AppIcon(
          icon: icon,
          color: isDetail ? AppColors.subText2 : color ?? AppColors.text2,
        ),
        AppSpacing.gapW8,
        Text(title,
            style: AppTextStyles.s14w500.copyWith(
                color: isDetail ? AppColors.subText2 : AppColors.text2)),
      ],
    ).clickable(() {
      onTap();
    });
  }

  void _onTapComment({
    bool autoFocus = false,
  }) {
    // ViewUtil.showBottomSheet(
    //   isFullScreen: true,
    //   isScrollControlled: true,
    //   settings: RouteSettings(
    //     arguments: CommentsArguments(
    //       postId: widget.post.id,
    //       isMyPost: widget.post.author.id == widget.currentUser.id,
    //       autoFocus: autoFocus,
    //     ),
    //   ),
    //   child: CommentView(
    //     bindingCreator: () => CommentsBinding(),
    //   ),
    // );
    Get.toNamed(
      Routes.postDetail,
      arguments: {
        'postId': widget.post.id,
        'isPostInHome': widget.isPostInHome,
        'isFocus': true,
      },
    );
    // Get.find<CommentInputController>().focusNode.requestFocus();
  }

  Widget _buildListImageOrVideo(
    List<Attachment> attachments,
    Post post, {
    EdgeInsets margin = const EdgeInsets.symmetric(),
  }) {
    // final ValueNotifier<int> indexMedia = ValueNotifier<int>(1);
    if (attachments.isEmpty) {
      return const SizedBox();
    }

    switch (attachments.length) {
      case 1:
        {
          return Container(
            margin: margin,
            width: 1.sw,
            constraints: BoxConstraints(maxHeight: 460.h),
            child: GestureDetector(
              onTap: () {
                _buildShowDialogImageOrVideo(
                  context: context,
                  attachments: attachments[0],
                  listAttachments: attachments,
                  index: 0,
                  post: post,
                );
              },
              child: _buildImageOrVideo(attachments[0], context),
            ),
          );
        }

      case 2:
        {
          return Row(
            children: [
              Container(
                margin: margin,
                width: 0.5.sw - 1.5,
                constraints: BoxConstraints(maxHeight: 460.h, minHeight: 460.h),
                child: GestureDetector(
                  onTap: () {
                    _buildShowDialogImageOrVideo(
                      context: context,
                      attachments: attachments[0],
                      listAttachments: attachments,
                      index: 0,
                      post: post,
                    );
                  },
                  child: _buildImageOrVideo(attachments[0], context),
                ),
              ),
              Container(
                color: Colors.white,
                width: 3,
              ),
              Container(
                margin: margin,
                width: 0.5.sw - 1.5,
                constraints: BoxConstraints(maxHeight: 460.h, minHeight: 460.h),
                child: GestureDetector(
                  onTap: () {
                    _buildShowDialogImageOrVideo(
                      context: context,
                      attachments: attachments[1],
                      listAttachments: attachments,
                      index: 1,
                      post: post,
                    );
                  },
                  child: _buildImageOrVideo(attachments[1], context),
                ),
              ),
            ],
          );
        }

      case 3:
        {
          return Column(
            children: [
              Container(
                margin: margin,
                width: 1.sw,
                constraints: BoxConstraints(
                    maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                child: GestureDetector(
                  onTap: () {
                    _buildShowDialogImageOrVideo(
                      context: context,
                      attachments: attachments[0],
                      listAttachments: attachments,
                      index: 0,
                      post: post,
                    );
                  },
                  child: _buildImageOrVideo(attachments[0], context),
                ),
              ),
              Container(
                color: Colors.white,
                height: 3,
              ),
              Row(
                children: [
                  Container(
                    margin: margin,
                    width: 0.5.sw - 1.5,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        _buildShowDialogImageOrVideo(
                          context: context,
                          attachments: attachments[1],
                          listAttachments: attachments,
                          index: 1,
                          post: post,
                        );
                      },
                      child: _buildImageOrVideo(attachments[1], context),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 3,
                  ),
                  Container(
                    margin: margin,
                    width: 0.5.sw - 1.5,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        _buildShowDialogImageOrVideo(
                          context: context,
                          attachments: attachments[2],
                          listAttachments: attachments,
                          index: 2,
                          post: post,
                        );
                      },
                      child: _buildImageOrVideo(attachments[2], context),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

      case 4:
        {
          return Column(
            children: [
              Container(
                margin: margin,
                width: 1.sw,
                constraints: BoxConstraints(
                    maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                child: GestureDetector(
                  onTap: () {
                    _buildShowDialogImageOrVideo(
                      context: context,
                      attachments: attachments[0],
                      listAttachments: attachments,
                      index: 0,
                      post: post,
                    );
                  },
                  child: _buildImageOrVideo(attachments[0], context),
                ),
              ),
              Container(
                color: Colors.white,
                height: 3,
              ),
              Row(
                children: [
                  Container(
                    margin: margin,
                    width: (1.sw - 6) / 3,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        _buildShowDialogImageOrVideo(
                          context: context,
                          attachments: attachments[1],
                          listAttachments: attachments,
                          index: 1,
                          post: post,
                        );
                      },
                      child: _buildImageOrVideo(attachments[1], context),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 3,
                  ),
                  Container(
                    margin: margin,
                    width: (1.sw - 6) / 3,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        _buildShowDialogImageOrVideo(
                          context: context,
                          attachments: attachments[2],
                          listAttachments: attachments,
                          index: 2,
                          post: post,
                        );
                      },
                      child: _buildImageOrVideo(attachments[2], context),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 3,
                  ),
                  Container(
                    margin: margin,
                    width: (1.sw - 6) / 3,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        _buildShowDialogImageOrVideo(
                          context: context,
                          attachments: attachments[3],
                          listAttachments: attachments,
                          index: 3,
                          post: post,
                        );
                      },
                      child: _buildImageOrVideo(attachments[3], context),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

      default:
        {
          return Column(
            children: [
              Container(
                margin: margin,
                width: 1.sw,
                constraints: BoxConstraints(
                    maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                child: GestureDetector(
                  onTap: () {
                    _buildShowDialogImageOrVideo(
                      context: context,
                      attachments: attachments[0],
                      listAttachments: attachments,
                      index: 0,
                      post: post,
                    );
                  },
                  child: _buildImageOrVideo(attachments[0], context),
                ),
              ),
              Container(
                color: Colors.white,
                height: 3,
              ),
              Row(
                children: [
                  Container(
                    margin: margin,
                    width: (1.sw - 6) / 3,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        _buildShowDialogImageOrVideo(
                          context: context,
                          attachments: attachments[1],
                          listAttachments: attachments,
                          index: 1,
                          post: post,
                        );
                      },
                      child: _buildImageOrVideo(attachments[1], context),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 3,
                  ),
                  Container(
                    margin: margin,
                    width: (1.sw - 6) / 3,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        _buildShowDialogImageOrVideo(
                          context: context,
                          attachments: attachments[2],
                          listAttachments: attachments,
                          index: 2,
                          post: post,
                        );
                      },
                      child: _buildImageOrVideo(attachments[2], context),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 3,
                  ),
                  Stack(
                    children: [
                      Container(
                        margin: margin,
                        width: (1.sw - 6) / 3,
                        constraints: BoxConstraints(
                            maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                        child: GestureDetector(
                          onTap: () {
                            _buildShowDialogImageOrVideo(
                              context: context,
                              attachments: attachments[3],
                              listAttachments: attachments,
                              index: 3,
                              post: post,
                            );
                          },
                          child: _buildImageOrVideo(attachments[3], context),
                        ),
                      ),
                      Container(
                        width: (1.sw - 6) / 3,
                        constraints: BoxConstraints(
                            maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                        color: AppColors.text2.withOpacity(0.3),
                        child: Center(
                          child: Text(
                            '+ ${attachments.length - 4}',
                            style: AppTextStyles.s24w600.text1Color,
                          ),
                        ),
                      ).clickable(() {
                        _buildShowDialogImageOrVideo(
                          context: context,
                          attachments: attachments[3],
                          listAttachments: attachments,
                          index: 3,
                          post: post,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ],
          );
        }
    }
    // return Container(
    //   margin: margin,
    //   child: Stack(children: [
    //     CarouselSlider.builder(
    //       options: CarouselOptions(
    //         height: 398.h,
    //         viewportFraction: 1,
    //         enableInfiniteScroll: false,
    //         onPageChanged: (int index, CarouselPageChangedReason reason) {
    //           indexMedia.value = index + 1;
    //         },
    //       ),
    //       itemCount: attachments.length,
    //       itemBuilder:
    //           (BuildContext context, int itemIndex, int pageViewIndex) {
    //         return GestureDetector(
    //           onTap: () {
    //             _buildShowDialogImageOrVideo(
    //               context: context,
    //               attachments: attachments[itemIndex],
    //               listAttachments: attachments,
    //               index: itemIndex,
    //             );
    //           },
    //           child: _buildImageOrVideo(attachments[itemIndex], context),
    //         );
    //       },
    //     ),
    //     if (attachments.length > 1)
    //       Positioned(
    //         top: 0,
    //         right: 0,
    //         child: ValueListenableBuilder(
    //           valueListenable: indexMedia,
    //           builder: (context, value, child) {
    //             return Container(
    //               margin: const EdgeInsets.only(right: 6, top: 6),
    //               decoration: const BoxDecoration(
    //                 color: AppColors.fieldBackground,
    //                 borderRadius: BorderRadius.all(Radius.circular(20)),
    //               ),
    //               child: Text(
    //                 '${indexMedia.value}/${attachments.length}',
    //                 style: AppTextStyles.s14w400,
    //               ).paddingSymmetric(vertical: Sizes.s8, horizontal: Sizes.s12),
    //             );
    //           },
    //         ),
    //       ),
    //     attachments.length > 1
    //         ? Positioned(
    //             bottom: 8,
    //             left: 0,
    //             right: 0,
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: attachments.asMap().entries.map((entry) {
    //                 return ValueListenableBuilder(
    //                   valueListenable: indexMedia,
    //                   builder: (context, value, child) {
    //                     return Container(
    //                       width: 8,
    //                       height: 8,
    //                       margin: const EdgeInsets.symmetric(horizontal: 4.0),
    //                       decoration: BoxDecoration(
    //                         shape: BoxShape.circle,
    //                         color: entry.key == (indexMedia.value - 1)
    //                             ? AppColors.white
    //                             : AppColors.fieldBackground,
    //                       ),
    //                     );
    //                   },
    //                 );
    //               }).toList(),
    //             ),
    //           )
    //         : const SizedBox.shrink(),
    //   ]),
    // );
  }

  Widget _buildImageOrVideo(Attachment attachment, BuildContext context) {
    if (attachment.isVideo) {
      return _buildVideoPlayer(
        context: context,
        url: attachment.path,
        thumbUrl: attachment.thumb ?? '',
        isProcessing: attachment.isProcessing ?? false,
      );
    }

    if (attachment.isImage) {
      return _buildImage(attachment, context);
    }

    return AppSpacing.emptyBox;
  }

  Widget _buildVideoPlayer({
    required BuildContext context,
    required String url,
    required String thumbUrl,
    bool isProcessing = false,
  }) {
    return FutureBuilder(
      future: getSizeImage(thumbUrl),
      builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
        if (snapshot.hasError) {
          return const SizedBox();
        }
        if (snapshot.hasData) {
          return Stack(
            children: [
              AppNetworkImage(
                thumbUrl,
                width: (snapshot.data?.width ?? 0) >
                        (ScreenUtil().screenWidth - 40.w)
                    ? snapshot.data?.width
                    : (ScreenUtil().screenWidth - 40.w),
                height: (snapshot.data?.height ?? 0) > 398.h
                    ? snapshot.data?.height
                    : 398.h,
                // radius: Sizes.s20,
                fit: BoxFit.cover,
                sizeLoading: Sizes.s32,
                colorLoading: AppColors.white,
              ),
              Positioned.fill(
                child: Align(
                  child: AppIcon(
                    icon: AppIcons.playAudio,
                    color: Colors.white,
                    size: Sizes.s32,
                  ),
                ),
              ),
            ],
          );
        }

        return const AppDefaultLoading(
          color: AppColors.white,
        );
      },
    );
  }

  Widget _buildImage(Attachment attachment, BuildContext context) {
    return AppNetworkImage(
      attachment.path,
      width: (attachment.width ?? 0) > (ScreenUtil().screenWidth - 40.w)
          ? attachment.width
          : (ScreenUtil().screenWidth - 40.w),
      height: (attachment.height ?? 0) > 398.h ? attachment.height : 398.h,
      // radius: Sizes.s20,
      fit: BoxFit.cover,
      sizeLoading: Sizes.s32,
      colorLoading: AppColors.white,
    );
  }

  void _buildShowDialogImageOrVideo({
    required BuildContext context,
    required Attachment attachments,
    required List<Attachment> listAttachments,
    required int index,
    required Post post,
  }) {
    Get.generalDialog(
      barrierColor: Colors.black87,
      barrierDismissible: true,
      barrierLabel: widget.post.id.toString(),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              alignment: Alignment.center,
              children: [
                CarouselSlider.builder(
                  options: CarouselOptions(
                    height: ScreenUtil().screenHeight,
                    initialPage: index,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    onPageChanged:
                        (int index, CarouselPageChangedReason reason) {},
                  ),
                  itemCount: listAttachments.length,
                  itemBuilder:
                      (BuildContext context, int itemIndex, int pageViewIndex) {
                    // Widget mediaWidget = AppSpacing.emptyBox;

                    // if (listAttachments[itemIndex].isVideo) {
                    //   mediaWidget = AppVideoPlayer(
                    //     listAttachments[itemIndex].path,
                    //     autoPlay: true,
                    //     width: 1.sw,
                    //     height: 1.sh,
                    //   );
                    // }

                    // if (listAttachments[itemIndex].isImage) {
                    //   mediaWidget = AppNetworkImage(
                    //     listAttachments[itemIndex].path,
                    //     fit: BoxFit.contain,
                    //     imageBuilder: (context, imageProvider) => Image(
                    //       image: imageProvider,
                    //       fit: BoxFit.contain,
                    //     ),
                    //   );
                    // }

                    // return Stack(
                    //   alignment: Alignment.center,
                    //   children: [
                    //     SizedBox(
                    //       width: 1.sw,
                    //       height: 1.sh,
                    //     ).clickable(Get.back),
                    //     Dismissible(
                    //       key: Key(widget.post.id.toString()),
                    //       direction: DismissDirection.down,
                    //       onDismissed: (_) => Get.back(),
                    //       child: GestureDetector(
                    //         onLongPress: () => _showMediaActionSheet(
                    //           context,
                    //           listAttachments[itemIndex],
                    //         ),
                    //         child: mediaWidget,
                    //       ),
                    //     ),
                    //   ],
                    // );
                    return ImageDetail(
                      attachments: listAttachments[itemIndex],
                      post: post,
                      currentUser: widget.currentUser,
                      onLike: widget.onLike,
                      onUnLike: widget.onUnLike,
                      onDelete: widget.onDelete,
                      onEdit: widget.onEdit,
                      onReport: widget.onReport,
                      onShare: widget.onShare,
                    );
                  },
                ),
                // Positioned(
                //   bottom: Sizes.s48.h,
                //   child: Padding(
                //     padding: AppSpacing.edgeInsetsAll16,
                //     child: AppIcon(
                //       icon: AppIcons.close,
                //       isCircle: true,
                //       padding: AppSpacing.edgeInsetsAll8,
                //       backgroundColor: Colors.white70,
                //       color: Colors.black,
                //     ),
                //   ).clickable(Get.back),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMediaActionSheet(BuildContext context, Attachment listAttachment) {
    final items = [
      ActionSheetItem(
        title: context.l10n.button__download,
        onPressed: () {
          FileUtil.saveNetworkAttachment(listAttachment).then(
            (_) => ViewUtil.showAppSnackBarNewFeeds(
              title: context.l10n.global__saved_label,
            ),
          );
        },
      ),
      // Report
      ActionSheetItem(
        title: context.l10n.button__report,
        onPressed: () {
          widget.onReport?.call(widget.post);
        },
      ),
      // Forward
      ActionSheetItem(
        title: context.l10n.button__forward,
        onPressed: () {
          widget.onShare?.call(widget.post);
        },
      ),
    ];

    ViewUtil.showActionSheet(
      items: items,
    );
  }

  void _buildShowBottomSheetMore(Post post, {required BuildContext context}) {
    Get.bottomSheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65,
            height: 4,
            margin: const EdgeInsets.only(bottom: Sizes.s16, top: Sizes.s12),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.text2,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.only(bottom: Sizes.s16, top: Sizes.s12),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.label,
            ),
            child: Column(
              children: [
                post.isMine(widget.currentUser.id)
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildItemMore(
                            title: context.l10n.newsfeed__edit_title,
                            icon: AppIcons.edit,
                            onTap: () => widget.onEdit?.call(post),
                          ),
                          _buildItemMore(
                            title: context.l10n.newsfeed__delete_title,
                            icon: AppIcons.delete,
                            onTap: () => widget.onDelete?.call(post),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                post.isMine(widget.currentUser.id)
                    ? const SizedBox.shrink()
                    : _buildItemMore(
                        title: context.l10n.newsfeed__report_title,
                        icon: AppIcons.report,
                        onTap: () => widget.onReport?.call(post),
                      ),
              ],
            ),
          ).paddingOnly(left: 20, right: 20, bottom: 20),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      backgroundColor: AppColors.white,
    );
  }

  Widget _buildItemMore({
    required String title,
    required SvgGenImage icon,
    Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          AppIcon(icon: icon, color: AppColors.text2),
          AppSpacing.gapW12,
          Text(title,
              style: AppTextStyles.s16w500.copyWith(color: AppColors.text2)),
        ],
      ).paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s12),
    );
  }

  void _showCopyContent(String content, BuildContext context) {
    final items = [
      ActionSheetItem(
        title: context.l10n.button__copy,
        onPressed: () {
          ViewUtil.copyToClipboard(content).then((_) =>
              ViewUtil.showAppSnackBarNewFeeds(
                  title: context.l10n.global__copied_to_clipboard));
        },
      ),
    ];

    ViewUtil.showActionSheet(
      items: items,
    );
  }

  Future<Size> getSizeImage(String url) async {
    final Image image = Image.network(url);
    final Completer<Size> completer = Completer<Size>();
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          final Size size =
              Size(info.image.width.toDouble(), info.image.height.toDouble());
          completer.complete(size);
        },
      ),
    );

    return completer.future;
  }

  Widget _buildOriginalPost({
    required Post postParent,
    required Post originalPost,
    required BuildContext context,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (originalPost.attachments.isEmpty) ...[
          Container(
            margin: const EdgeInsets.only(
              left: Sizes.s20,
              right: Sizes.s20,
            ),
            padding: const EdgeInsets.only(
              left: Sizes.s12,
              right: Sizes.s12,
              top: Sizes.s12,
              bottom: Sizes.s12,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.subText2, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderOriginalPost(
                  context,
                  originalPost: originalPost,
                ),
                if ((originalPost.content ?? '').isNotEmpty)
                  GestureDetector(
                    onLongPress: () {
                      _showCopyContent(originalPost.content ?? '', context);
                    },
                    child: ExpandableText(
                      (originalPost.content ?? '').trim(),
                      expandText: context.l10n.global__show_more_label,
                      collapseText: context.l10n.global__show_less_label,
                      maxLines: 4,
                      textAlign: TextAlign.left,
                      style: AppTextStyles.s14w500.text2Color,
                      linkColor: AppColors.zambezi,
                      onUrlTap: (url) {
                        IntentUtils.openBrowserURL(url: url);
                      },
                      urlStyle: AppTextStyles.s12w500.text4Color,
                    ),
                  ),
                _buildListImageOrVideo(
                  originalPost.attachments,
                  originalPost,
                  margin: const EdgeInsets.only(
                    top: Sizes.s12,
                  ),
                ),
              ],
            ),
          )
        ] else ...[
          Container(
            margin: const EdgeInsets.only(
              left: Sizes.s20,
              right: Sizes.s20,
            ),
            padding: const EdgeInsets.only(
              left: Sizes.s12,
              right: Sizes.s12,
              top: Sizes.s12,
              bottom: Sizes.s12,
            ),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: AppColors.subText2, width: 0.5),
                  left: BorderSide(color: AppColors.subText2, width: 0.5),
                  right: BorderSide(color: AppColors.subText2, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderOriginalPost(
                  context,
                  originalPost: originalPost,
                ),
                if ((originalPost.content ?? '').isNotEmpty)
                  GestureDetector(
                    onLongPress: () {
                      _showCopyContent(originalPost.content ?? '', context);
                    },
                    child: ExpandableText(
                      (originalPost.content ?? '').trim(),
                      expandText: context.l10n.global__show_more_label,
                      collapseText: context.l10n.global__show_less_label,
                      maxLines: 4,
                      textAlign: TextAlign.left,
                      style: AppTextStyles.s14w500.text2Color,
                      linkColor: AppColors.zambezi,
                      onUrlTap: (url) {
                        IntentUtils.openBrowserURL(url: url);
                      },
                      urlStyle: AppTextStyles.s12w500.text4Color,
                    ),
                  ),
              ],
            ),
          ),
          _buildListImageOrVideo(originalPost.attachments, originalPost),
        ],
      ],
    );
  }

  Widget _buildHeaderOriginalPost(
    BuildContext context, {
    required Post originalPost,
  }) {
    return Row(
      children: [
        AppCircleAvatar(
          url: originalPost.author.avatarPath ?? '',
          size: 40,
        ).clickable(() {
          widget.onGoToPersonal?.call(originalPost.author);
        }),
        AppSpacing.gapW12,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              originalPost.author.fullName,
              style: AppTextStyles.s14w600.copyWith(color: AppColors.text2),
            ).clickable(() {
              widget.onGoToPersonal?.call(originalPost.author);
            }),
            AppSpacing.gapH4,
            Text(
              DateTimeUtil.timeAgo(context, originalPost.createdAt),
              style: AppTextStyles.s12w400.subText2Color,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSharePostToDelete({required BuildContext context}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.s20,
        vertical: Sizes.s12,
      ),
      margin: const EdgeInsets.only(
        left: Sizes.s20,
        right: Sizes.s20,
      ),
      decoration: BoxDecoration(
        color: AppColors.subText2.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Sizes.s20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, color: AppColors.subText2),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.newsfeed__share_post_delete_title,
                  style: AppTextStyles.s14w600.text2Color,
                ),
                Text(
                  context.l10n.newsfeed__share_post_delete_content,
                  style: AppTextStyles.s12w400.subText2Color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
