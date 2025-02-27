import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';

import '../../../../../../../../core/all.dart';
import '../../../../../../../../models/all.dart';
import '../../../../../../../resource/styles/app_colors.dart';
import '../../../../../../../resource/styles/gaps.dart';
import '../../../../../../../resource/styles/text_styles.dart';
import 'text_message_widget.dart';

class PreviewHyperTextMessageWidget extends StatelessWidget {
  final bool isMine;
  final Message message;
  final List<User> members;
  final Function(String? mention, Map<String, int> mentionUserIdMap)
      onMentionPressed;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final bool isTextEllipsis;
  final bool isShowLinkPreview;
  final int? maxLines;
  final bool isPreviewReply;

  const PreviewHyperTextMessageWidget({
    required this.isMine,
    required this.message,
    required this.members,
    required this.onMentionPressed,
    super.key,
    this.padding,
    this.backgroundColor,
    this.isTextEllipsis = false,
    this.isShowLinkPreview = true,
    this.maxLines,
    this.isPreviewReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        PreviewTextMessageWidget(
          isMine: isMine,
          message: message,
          members: members,
          onMentionPressed: onMentionPressed,
          padding: padding,
          backgroundColor: backgroundColor,
          isTextEllipsis: isTextEllipsis,
          maxLines: maxLines,
          isPreviewReply: isPreviewReply,
        ),
        if (isShowLinkPreview && message.linksInContent.isNotEmpty)
          ...message.linksInContent.map((link) {
            return Container(
              decoration: BoxDecoration(
                color: isMine
                    ? AppColors.popup.withOpacity(0.22)
                    : AppColors.label1Color.withOpacity(0.58),
                borderRadius: AppRadius.borderRadius12,
              ),
              margin: AppSpacing.edgeInsetsOnlyTop4,
              child: Material(
                color: Colors.white,
                child: AnyLinkPreview(
                  link: link,
                  bodyMaxLines: 5,
                  borderRadius: 12,
                  cache: const Duration(days: 5),
                  backgroundColor: Colors.white,
                  titleStyle: AppTextStyles.s16w600.text2Color,
                  bodyStyle: AppTextStyles.s12w400.subText2Color,
                  onTap: () => IntentUtils.openBrowserURL(url: link),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
