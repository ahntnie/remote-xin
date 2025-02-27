part of '_root_comment_item.dart';

class _CommentItem extends StatelessWidget {
  final Comment comment;
  final bool isShowReplyButton;
  final bool isMyPost;
  final bool isRoot;
  final bool isLast;
  final bool isExpand;

  final VoidCallback onLikePressed;
  final VoidCallback onReplyPressed;
  final VoidCallback onDeleteComment;
  final VoidCallback onEditComment;

  const _CommentItem({
    required this.comment,
    required this.onLikePressed,
    required this.onReplyPressed,
    required this.onDeleteComment,
    required this.onEditComment,
    required this.isMyPost,
    required this.isRoot,
    required this.isLast,
    required this.isExpand,
    this.isShowReplyButton = true,
    super.key,
  });

  void _showActionSheet(BuildContext context) {
    final isMyComment =
        comment.isMine(Get.find<AppController>().currentUser.id);

    if (!isMyComment && !isMyPost) {
      return;
    }

    {
      ViewUtil.showActionSheet(
        items: [
          ActionSheetItem(
            title: context.l10n.comments__delete_comment_title,
            onPressed: () => _showConfirmDeleteDialog(context),
          ),
          if (isMyComment)
            ActionSheetItem(
              title: context.l10n.comments__edit_comment_label,
              onPressed: onEditComment,
            ),
        ],
      );
    }
  }

  void _showConfirmDeleteDialog(BuildContext context) {
    ViewUtil.showAppCupertinoAlertDialog(
      title: context.l10n.comments__delete_comment_title,
      message: context.l10n.comments__delete_comment_confirm,
      negativeText: context.l10n.button__cancel,
      positiveText: context.l10n.button__confirm,
      onPositivePressed: onDeleteComment,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;
    final EdgeInsets padding = EdgeInsets.only(
        left: isRTL ? 0 : Sizes.s32 + 8.0,
        bottom: 8,
        top: 8,
        right: isRTL ? Sizes.s32 + 8.0 : 0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _showActionSheet(context),
      child: isRoot
          ? isExpand
              ? CustomPaint(
                  painter: RootPainter(
                    const Size.fromRadius(16),
                    AppColors.grey6,
                    2,
                    Directionality.of(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildComment(context),
                      _buildActionButtons(context),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildComment(context),
                    _buildActionButtons(context),
                  ],
                )
          : CustomPaint(
              painter: _Painter(
                isLast: isLast,
                padding: padding,
                textDirection: Directionality.of(context),
                avatarRoot: const Size.fromRadius(16),
                avatarChild: const Size.fromRadius(16),
                pathColor: AppColors.grey6,
                strokeWidth: 2,
              ),
              child: Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildComment(context),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildComment(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCircleAvatar(
          size: Sizes.s32,
          url: comment.author.avatarPath ?? '',
        ),
        AppSpacing.gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: AppColors.label,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.author.displayName,
                          style: AppTextStyles.s14w700.text2Color,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // AppSpacing.gapW8,
                        // Text(
                        //   DateTimeUtil.timeAgo(context, comment.createdAt),
                        //   style: AppTextStyles.s12w400.subText2Color,
                        // ),
                      ],
                    ),
                    _buildTextComment(context),
                  ],
                ),
              ),
              _buildCommentMedia(context),
            ],
          ),
        ),
        // _buildLikeButton(context),
      ],
    );
  }

  Widget _buildTextComment(BuildContext context) {
    if (comment.content == null) {
      return AppSpacing.emptyBox;
    }

    return Padding(
      padding: AppSpacing.edgeInsetsOnlyTop4,
      child: !comment.comment.containsLink()
          ? Text(
              comment.comment,
              style: AppTextStyles.s14w400.text2Color,
            )
          : ExpandableText(
              comment.comment,
              expandText: context.l10n.global__show_more_label,
              collapseText: context.l10n.global__show_less_label,
              maxLines: 4,
              textAlign: TextAlign.left,
              style: AppTextStyles.s14w400.text2Color,
              linkColor: AppColors.zambezi,
              onUrlTap: (url) {
                IntentUtils.openBrowserURL(url: url);
              },
              urlStyle: AppTextStyles.s14w400.text4Color,
            ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return _buildReplyButton(context);
  }

  Widget _buildLikeButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSpacing.gapH4,
        AppIcon(
          icon: comment.isLiked ? AppIcons.reacted : AppIcons.react,
          color: comment.isLiked ? AppColors.reacted : Colors.black,
          size: Sizes.s16,
          padding: AppSpacing.edgeInsetsAll4,
        ),
        Text(
          comment.likeCount.toString(),
          style: AppTextStyles.s12w400.subText2Color,
        ),
      ],
    ).clickable(onLikePressed);
  }

  Widget _buildReplyButton(BuildContext context) {
    // if (!isShowReplyButton) {
    //   return AppSpacing.emptyBox;
    // }

    return Padding(
      padding: const EdgeInsets.only(left: 32 + 12, top: 6),
      child: Row(
        children: [
          Text(
            DateTimeUtil.timeAgo(context, comment.createdAt),
            style: AppTextStyles.s14w400.subText2Color,
          ),
          AppSpacing.gapW12,
          Text(
            context.l10n.newsfeed__like,
            style: AppTextStyles.s14w600.text2Color.copyWith(
                color: comment.isLiked ? AppColors.text2 : AppColors.subText,
                fontWeight: comment.isLiked ? FontWeight.bold : null),
          ).clickable(onLikePressed),
          AppSpacing.gapW12,
          if (isRoot)
            Text(
              context.l10n.comments__reply_label,
              style: AppTextStyles.s14w600.copyWith(color: AppColors.subText),
            ).clickable(onReplyPressed),
          const Spacer(),
          if (comment.likeCount > 0) ...[
            Text(
              comment.likeCount.toString(),
              style: AppTextStyles.s14w400.copyWith(color: AppColors.subText),
            ),
            AppSpacing.gapW4,
            AppIcon(
              icon: AppIcons.reacted,
              color: comment.isLiked ? AppColors.reacted : AppColors.text2,
              size: Sizes.s16,
              padding: AppSpacing.edgeInsetsAll4,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentMedia(BuildContext context) {
    if (comment.firstAttachment == null) {
      return AppSpacing.emptyBox;
    }

    return Padding(
      padding: AppSpacing.edgeInsetsV12,
      child: AttachmentWidget(
        key: Key(comment.firstAttachment!.path),
        attachment: comment.firstAttachment!,
        width: 120.w,
        height: 200.h,
      ),
    );
  }
}

class RootPainter extends CustomPainter {
  Size? avatar;
  late Paint _paint;
  Color? pathColor;
  double? strokeWidth;
  final TextDirection textDecoration;
  RootPainter(
      this.avatar, this.pathColor, this.strokeWidth, this.textDecoration) {
    _paint = Paint()
      ..color = pathColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth!
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (textDecoration == TextDirection.rtl) canvas.translate(size.width, 0);
    double dx = avatar!.width / 2;
    if (textDecoration == TextDirection.rtl) dx *= -1;
    canvas.drawLine(
      Offset(dx, avatar!.height),
      Offset(dx, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _Painter extends CustomPainter {
  bool isLast = false;

  EdgeInsets? padding;
  final TextDirection textDirection;
  Size? avatarRoot;
  Size? avatarChild;
  Color? pathColor;
  double? strokeWidth;

  _Painter({
    required this.isLast,
    required this.textDirection,
    this.padding,
    this.avatarRoot,
    this.avatarChild,
    this.pathColor,
    this.strokeWidth,
  }) {
    _paint = Paint()
      ..color = pathColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth!
      ..strokeCap = StrokeCap.round;
  }

  late Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    if (textDirection == TextDirection.rtl) canvas.translate(size.width, 0);
    double rootDx = avatarRoot!.width / 2;
    if (textDirection == TextDirection.rtl) rootDx *= -1;
    path.moveTo(rootDx, 0);
    path.cubicTo(
      rootDx,
      0,
      rootDx,
      padding!.top + avatarChild!.height / 2,
      rootDx * 2,
      padding!.top + avatarChild!.height / 2,
    );
    canvas.drawPath(path, _paint);

    if (!isLast) {
      canvas.drawLine(
        Offset(rootDx, 0),
        Offset(rootDx, size.height),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
