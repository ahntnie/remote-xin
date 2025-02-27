import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/comment.dart';
import '../../../../common_controller.dart/app_controller.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../widgets/all.dart';
import '../controllers/root_comment_controller.dart';

part '_comment_item.dart';

class RootCommentItem extends GetWidget<RootCommentController> {
  final Comment comment;
  final bool isMyPost;

  const RootCommentItem({
    required this.comment,
    required this.isMyPost,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    controller.injectRootComment(comment);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRootComment(),
        Obx(
          () => controller.isExpanded
              ? _buildChildComments(context)
              : _buildViewRepliesButton(context),
        ),
      ],
    );
  }

  Widget _buildRootComment() {
    return Obx(
      () => _CommentItem(
        key: ValueKey(comment.id),
        comment: controller.rootComment,
        isMyPost: isMyPost,
        onLikePressed: () => controller.onLikePressed(controller.rootComment),
        onReplyPressed: () => controller.onReplyPressed(controller.rootComment),
        onDeleteComment: () => controller.deleteComment(controller.rootComment),
        onEditComment: () => controller.editComment(comment),
        isRoot: true,
        isLast: false,
        isExpand: controller.isExpanded,
      ),
    );
  }

  Widget _buildViewRepliesButton(BuildContext context) {
    if (controller.rootComment.childrenCount == 0) {
      return AppSpacing.emptyBox;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 32 + 12, top: 12),
      child: Text(
        context.l10n.comments__see_replies_label,
        style: AppTextStyles.s14w600.subText2Color,
      ).clickable(controller.getReplies),
    );
  }

  Widget _childCommentsLoading({double height = 20}) {
    return SizedBox(
      height: height,
      child: const AppDefaultLoading(size: Sizes.s16),
    );
  }

  Widget _buildChildComments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonPagedListView<Comment>(
          padding: EdgeInsets.zero,
          pagingController: controller.pagingController,
          separatorBuilder: (context, index) => AppSpacing.emptyBox,
          newPageProgressIndicator: _buildLoadMoreButton(context),
          firstPageProgressIndicator: _childCommentsLoading(height: 56),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, comment, index) {
            return _CommentItem(
              key: ValueKey(comment.id),
              comment: comment,
              isShowReplyButton: false,
              isMyPost: isMyPost,
              onLikePressed: () => controller.onLikePressed(comment),
              onReplyPressed: () => controller.onReplyPressed(comment),
              onDeleteComment: () => controller.deleteComment(comment),
              onEditComment: () => controller.editComment(comment),
              isRoot: false,
              isLast: index == controller.pagingController.itemList!.length - 1,
              isExpand: false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    if (controller.paginatedList.isLastPage) {
      return AppSpacing.emptyBox;
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 32 + 12,
        top: 12,
      ),
      child: Text(
        context.l10n.comments__load_more_replies_label,
        style: AppTextStyles.s14w600.subText2Color,
      ).clickable(controller.onEndScroll),
    );
  }
}
