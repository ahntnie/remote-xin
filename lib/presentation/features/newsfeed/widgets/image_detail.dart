import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../../all.dart';
import '../comments/bindings/comments_binding.dart';
import '../comments/controllers/comment_input_controller.dart';

class ImageDetail extends StatefulWidget {
  final Attachment attachments;
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
  const ImageDetail({
    required this.attachments,
    required this.post,
    required this.currentUser,
    required this.onLike,
    required this.onUnLike,
    super.key,
    this.onDelete,
    this.onEdit,
    this.onReport,
    this.onShare,
    this.onGoToPersonal,
    this.isShowComment = false,
    this.isPostInHome = true,
    this.isPostDetail = false,
  });

  @override
  State<ImageDetail> createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
  late PageController _pageController;
  bool isLike = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLike = widget.post.userReaction == null ? false : true;
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DismissiblePage(
          onDismissed: () => Navigator.of(context).pop(),
          // Start of the optional properties
          isFullScreen: false,
          minRadius: 10,
          maxRadius: 10,
          dragSensitivity: 1.0,
          maxTransformValue: .8,
          direction: DismissiblePageDismissDirection.multi,
          // onDragStart: () {
          //   print('onDragStart');
          // },
          // onDragUpdate: (details) {
          //   print(details);
          // },
          dismissThresholds: const {
            DismissiblePageDismissDirection.vertical: .2,
          },
          minScale: .8,
          reverseDuration: const Duration(milliseconds: 250),
          // End of the optional properties
          child: widget.attachments.isImage
              ? PhotoViewGallery.builder(
                  builder: (BuildContext context, int index) =>
                      PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(widget.attachments.path),
                    maxScale: 4.0,
                    minScale: PhotoViewComputedScale.contained,
                  ),
                  itemCount: 1,
                  // loadingBuilder: (context, event) =>
                  //     _imageGalleryLoadingBuilder(event),
                  pageController: _pageController,
                  scrollPhysics: const ClampingScrollPhysics(),
                )
              : AppVideoPlayer(
                  widget.attachments.path,
                  autoPlay: true,
                  width: 1.sw,
                  height: 1.sh,
                ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpacing.gapH8,
                Text(
                  widget.post.author.fullName,
                  style: AppTextStyles.s16w700.text1Color,
                ).paddingSymmetric(horizontal: 20),
                Row(
                  children: [
                    Text(
                      DateTimeUtil.timeAgo(context, widget.post.createdAt),
                      style: AppTextStyles.s12w500.toColor(AppColors.zambezi),
                    ),
                    AppSpacing.gapW4,
                    AppIcon(
                      icon: AppIcons.public,
                      color: AppColors.zambezi,
                      size: 16,
                    )
                  ],
                ).paddingSymmetric(horizontal: 20),
                AppSpacing.gapH12,
                Text(widget.post.content ?? '')
                    .paddingSymmetric(horizontal: 20),
                AppSpacing.gapH32,
                _buildAction(context, post: widget.post, isDetail: true),
                AppSpacing.gapH32,
              ],
            ),
          ),
        ),
        SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(icon: AppIcons.arrowLeft).clickable(() {
                Navigator.of(context).pop();
              }),
              const Spacer(),
              AppIcon(
                icon: Assets.icons.moreOption,
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              ).clickable(() =>
                  _buildShowBottomSheetMore(widget.post, context: context))
            ],
          ).paddingOnly(left: 20),
        ),
      ],
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
      ).paddingOnly(bottom: Sizes.s20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      backgroundColor: AppColors.white,
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
              icon: isLike == false
                  ? Assets.icons.unlikeeeeeeeeeee
                  : AppIcons.reacted,
              // icon: AppIcons.addContact,
              color: isLike == false ? AppColors.subText2 : AppColors.reacted,
              onTap: () {
                if (post.userReaction == null) {
                  HapticFeedback.lightImpact();
                  widget.onLike(post);
                } else {
                  widget.onUnLike(post);
                }
                setState(() {
                  isLike = !isLike;
                });
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
        ]
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

  void _onTapComment({
    bool autoFocus = false,
  }) {
    ViewUtil.showBottomSheet(
      isFullScreen: true,
      isScrollControlled: true,
      settings: RouteSettings(
        arguments: CommentsArguments(
          postId: widget.post.id,
          isMyPost: widget.post.author.id == widget.currentUser.id,
          autoFocus: autoFocus,
        ),
      ),
      child: CommentView(
        isShowHeader: true,
        post: widget.post,
        onLike: widget.onLike,
        onUnLike: widget.onUnLike,
        bindingCreator: () => CommentsBinding(),
      ),
    );
  }
}
