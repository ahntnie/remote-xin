import 'package:flutter/material.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';
import 'hyper_text_message_widget.dart';
import 'text_message_widget.dart';

class ReplyMessagePreviewWidget extends StatelessWidget {
  final Message message;
  final Function() onCloseMessage;
  final bool isMine;
  final List<User> members;
  final Function(String? mention, Map<String, int> mentionUserIdMap)
      onMentionPressed;

  const ReplyMessagePreviewWidget({
    required this.message,
    required this.onCloseMessage,
    required this.isMine,
    required this.members,
    required this.onMentionPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: Sizes.s8, left: Sizes.s20, right: Sizes.s20, bottom: Sizes.s16),
      decoration: const BoxDecoration(
          color: AppColors.text1,
          border: Border(top: BorderSide(color: AppColors.grey8, width: 0.3))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.sender != null)
                  ContactDisplayNameText(
                    user: message.sender!,
                    style: AppTextStyles.s16w700.copyWith(
                      color: AppColors.text2,
                    ),
                  ),
                contentMessage(context, message),
              ],
            ),
          ),
          InkWell(
            onTap: onCloseMessage,
            child: const AppIcon(
              icon: Icons.close,
              color: AppColors.text2,
              // isCircle: true,
              size: 20,
              // backgroundColor: AppColors.grey7,
            ),
          ),
        ],
      ),
    );
  }

  Widget contentMessage(BuildContext context, Message message) {
    final l10n = context.l10n;

    return switch (message.type) {
      MessageType.text => TextMessageWidget(
          isMine: isMine,
          message: message,
          members: members,
          onMentionPressed: onMentionPressed,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          isTextEllipsis: true,
          maxLines: 2,
          isPreviewReply: true,
        ),
      MessageType.hyperText => HyperTextMessageWidget(
          isMine: isMine,
          message: message,
          members: members,
          onMentionPressed: onMentionPressed,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          isTextEllipsis: true,
          isShowLinkPreview: false,
          maxLines: 2,
          isPreviewReply: true,
        ),
      MessageType.image => textWidget(l10n.conversation__pinned_image),
      MessageType.video => textWidget(l10n.conversation__pinned_video),
      MessageType.audio => textWidget(l10n.conversation__pinned_audio),
      MessageType.call => textWidget(l10n.conversation__pinned_call),
      MessageType.file => textWidget(l10n.conversation__pinned_file),
      MessageType.post => textWidget(l10n.conversation__pinned_post),
      MessageType.sticker => textWidget(l10n.conversation__pinned_sticker),
      MessageType.system => textWidget(context.l10n.chat__sent_system_message),
    };
  }

  Widget textWidget(String text) {
    return Text(
      text,
      style: AppTextStyles.s14w600.toColor(AppColors.grey8),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
