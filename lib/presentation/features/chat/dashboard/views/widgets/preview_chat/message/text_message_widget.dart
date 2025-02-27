import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_text/styled_text.dart';

import '../../../../../../../../core/all.dart';
import '../../../../../../../../models/all.dart';
import '../../../../../../../resource/styles/app_colors.dart';
import '../../../../../../../resource/styles/gaps.dart';
import '../../../../../../../resource/styles/text_styles.dart';

class PreviewTextMessageWidget extends StatelessWidget {
  final bool isMine;
  final Message message;
  final List<User> members;
  final Function(String? mention, Map<String, int> mentionUserIdMap)
      onMentionPressed;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final bool isTextEllipsis;
  final int? maxLines;
  final bool isReply;
  final bool isPreviewReply;

  const PreviewTextMessageWidget({
    required this.isMine,
    required this.message,
    required this.members,
    required this.onMentionPressed,
    super.key,
    this.padding,
    this.backgroundColor,
    this.isTextEllipsis = false,
    this.maxLines,
    this.isReply = false,
    this.isPreviewReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color:
              backgroundColor ?? (isMine ? AppColors.blue5 : AppColors.grey7),
          borderRadius: BorderRadius.circular(
            Sizes.s20,
          )),
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: Sizes.s24,
            vertical: Sizes.s8,
          ),
      child: Builder(
        builder: (context) {
          if (message.isMentionedMessage ||
              message.type == MessageType.hyperText) {
            String content = message.content;

            final mentionedUserIds = message.mentionedUserIds;

            final mentionUserIdMap = <String, int>{};

            for (final userId in mentionedUserIds) {
              final user = members.firstWhereOrNull(
                (element) => element.id == userId,
              );

              final mentionKey = userIdMentionWrapper.replaceAll(
                'userId',
                userId.toString(),
              );

              final String? userFullName =
                  user?.contact?.fullName ?? user?.fullName;

              final toReplace =
                  '<${AppConstants.mentionTag}>@${(userFullName ?? '').trim()}</${AppConstants.mentionTag}>';

              mentionUserIdMap[toReplace] = userId;
              content = content.replaceAll(
                mentionKey,
                toReplace,
              );
            }

            return StyledText(
              text: content,
              overflow:
                  isTextEllipsis ? TextOverflow.ellipsis : TextOverflow.clip,
              style: AppTextStyles.s14w400.toColor(
                isMine ? AppColors.text1 : AppColors.text2,
              ),
              maxLines: maxLines,
              tags: {
                AppConstants.mentionTag: StyledTextActionTag(
                  (mention, _) => onMentionPressed(mention, mentionUserIdMap),
                  style: AppTextStyles.s14w400.copyWith(
                    color: isMine ? Colors.white : Colors.black,
                    decoration: TextDecoration.underline,
                    decorationColor: isMine ? Colors.white : Colors.black,
                  ),
                ),
                AppConstants.hyperTextTag: StyledTextActionTag(
                  (hyper, _) {
                    if (hyper == null) {
                      return;
                    }
                    if (hyper.contains(Get.find<EnvConfig>().jitsiUrl)) {
                      // final List<String> parts = hyper.split('/');

                      // final String idMeeting = parts[3];
                    } else {
                      IntentUtils.openBrowserURL(url: hyper);
                    }
                  },
                  style: AppTextStyles.s14w400.copyWith(
                    color: isPreviewReply
                        ? AppColors.grey8
                        : isMine
                            ? Colors.white
                            : Colors.black,
                    decoration: TextDecoration.underline,
                    decorationColor: isPreviewReply
                        ? AppColors.grey8
                        : isMine
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              },
            );
          }

          return Text(
            message.content,
            overflow:
                isTextEllipsis ? TextOverflow.ellipsis : TextOverflow.clip,

            // style: AppTextStyles.s14w400.toColor(
            //   isPreviewReply
            //       ? AppColors.grey8
            //       : isReply
            //           ? AppColors.text2
            //           : isMine
            //               ? AppColors.text1
            //               : AppColors.text2,
            // ),
            style: AppTextStyles.s14w400.copyWith(
              decoration: TextDecoration.none,
              color: isPreviewReply
                  ? AppColors.grey8
                  : isReply
                      ? AppColors.text2
                      : isMine
                          ? AppColors.text1
                          : AppColors.text2,
            ),
            maxLines: maxLines,
          );
        },
      ),
    );
  }
}
