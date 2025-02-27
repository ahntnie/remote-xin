import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/comment.dart';
import '../../../../../models/post.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../common_widgets/app_blurry_container.dart';
import '../../../../resource/resource.dart';
import '../bindings/comments_binding.dart';
import '../controllers/comment_input_controller.dart';
import '../controllers/comments_controller.dart';
import '_root_comment_item.dart';
import 'comment_input.dart';

class CommentView extends BaseView<CommentsController> {
  const CommentView({
    super.key,
    this.bindingCreator,
    this.isPostDetail = false,
    this.postId = 0,
    this.isMyPost = false,
    this.isShowHeader = false,
    this.post,
    this.onLike,
    this.onUnLike,
  });

  final CommentsBinding Function()? bindingCreator;
  final bool isPostDetail;
  final int postId;
  final bool isMyPost;
  final bool isShowHeader;
  final Post? post;
  final Function(Post post)? onLike;
  final Function(Post post)? onUnLike;

  void _createBinding() {
    Get.lazyPut<CommentsController>(() => CommentsController(
        isMyPostPostDetail: isMyPost,
        postIdPostDetail: postId,
        isPostDetail: isPostDetail));
    Get.lazyPut<CommentInputController>(() => CommentInputController(
        isMyPostPostDetail: isMyPost,
        postIdPostDetail: postId,
        isPostDetail: isPostDetail));
    final Bindings? binding = bindingCreator?.call();

    binding?.dependencies();
  }

  @override
  Widget buildPage(BuildContext context) {
    _createBinding();

    if (isPostDetail) {
      return _buildCommentList()
          .clickable(() => ViewUtil.hideKeyboard(context));
    }

    return AppBlurryContainer(
      padding: EdgeInsets.zero,
      // borderRadius: 30,
      // color: AppColors.opacityBackground,
      child: Container(
        padding: const EdgeInsets.only(
          top: Sizes.s16,
          bottom: Sizes.s8,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Sizes.s20),
            topRight: Radius.circular(Sizes.s20),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildCommentList()),
            const CommentInput(),
          ],
        ),
      ),
    ).clickable(
      () => ViewUtil.hideKeyboard(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: AppColors.text2,
          ),
        ),
        if (isShowHeader && post != null) ...[
          AppSpacing.gapH20,
          if (post!.likeCount != 0)
            Row(
              children: [
                AppIcon(
                  icon: AppIcons.reacted,
                  size: 16,
                ),
                AppSpacing.gapW8,
                Text(
                  context.l10n.newsfeed__like_count(
                    NumberFormatConstants.formatNumber(post!.likeCount),
                  ),
                  style: AppTextStyles.s16w700.toColor(AppColors.text2),
                ),
                const Spacer(),
                // _buildActionItem(
                //   title: '',
                //   isDetail: false,
                //   icon: post!.userReaction == null
                //       ? AppIcons.react
                //       : AppIcons.reacted,
                //   color: post!.userReaction == null
                //       ? AppColors.subText2
                //       : AppColors.reacted,
                //   onTap: () {
                //     if (post!.userReaction == null) {
                //       HapticFeedback.lightImpact();
                //       onLike!(post!);
                //     } else {
                //       onUnLike!(post!);
                //     }
                //   },
                // ),
              ],
            ),
        ],
      ],
    ).paddingOnly(bottom: Sizes.s20, left: 20, right: 20);
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

  Widget _buildCommentList() {
    return Padding(
      padding: AppSpacing.edgeInsetsH20,
      child: CommonPagedListView<Comment>(
        padding: isPostDetail ? EdgeInsets.zero : null,
        shrinkWrap: isPostDetail,
        physics: isPostDetail ? const NeverScrollableScrollPhysics() : null,
        pagingController: controller.pagingController,
        separatorBuilder: (context, index) => AppSpacing.gapH16,
        noItemsFoundIndicator: const _NoCommentsFound(),
        itemBuilder: (context, comment, index) {
          return RootCommentItem(
            key: ValueKey(comment.id),
            comment: comment,
            isMyPost: controller.isMyPost,
          );
        },
      ),
    );
  }
}

class _NoCommentsFound extends StatelessWidget {
  const _NoCommentsFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.comments__no_comments_title,
            style: AppTextStyles.s16w600.text2Color,
          ),
          AppSpacing.gapH4,
          Text(
            context.l10n.comments__no_comments_message,
            style: AppTextStyles.s14w400.subText2Color,
          ),
        ],
      ),
    );
  }
}
