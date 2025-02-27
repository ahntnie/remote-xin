import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:styled_text/styled_text.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/all.dart';
import '../../../../../base/all.dart';
import '../../../../../resource/resource.dart';
import '../../../../all.dart';

class TextMessageController extends BaseController {
  final isFlashing = false.obs;

  RxString tag = ''.obs;

  void triggerFlash(String id) {
    tag.value = id;
    isFlashing.value = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
      isFlashing.value = false;
    });
  }
}

class TextMessageWidget extends BaseView<TextMessageController> {
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
  final bool isReaction;

  const TextMessageWidget({
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
    this.isReaction = false,
  });

  @override
  Widget buildPage(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
            color: controller.isFlashing.value &&
                    controller.tag.value == message.id
                ? AppColors.blue7
                : backgroundColor ??
                    (isMine ? AppColors.blue5 : AppColors.grey7),
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

                String? userFullName =
                    user?.contact?.fullName ?? user?.fullName;

                if (userFullName == null) {
                  final originMentionUserName =
                      message.mentions?.keys.toList().firstWhereOrNull(
                            (element) => element.contains(mentionKey),
                          );

                  userFullName = originMentionUserName;
                }

                if (userFullName != null) {
                  final toReplace =
                      '<${AppConstants.mentionTag}>@${userFullName.trim()}</${AppConstants.mentionTag}>';

                  mentionUserIdMap[toReplace] = userId;
                  content = content.replaceAll(
                    mentionKey,
                    toReplace,
                  );
                }
              }

              return isReaction
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          constraints: BoxConstraints(maxHeight: 0.4.sh),
                          child: SingleChildScrollView(
                            child: contentHyperText(
                                context, content, mentionUserIdMap),
                          ),
                        );
                      },
                    )
                  : contentHyperText(context, content, mentionUserIdMap);
            }

            return isReaction
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final textStyle = AppTextStyles.s16w500.toColor(
                        isPreviewReply
                            ? AppColors.text1
                            : isMine
                                ? AppColors.white
                                : AppColors.text1,
                      );

                      final textPainter = TextPainter(
                        text: TextSpan(
                          text: message.getDisplayContent,
                          style: textStyle,
                        ),
                        textDirection: TextDirection.ltr,
                      )..layout(maxWidth: constraints.maxWidth);

                      final lineMetrics = textPainter.computeLineMetrics();
                      final isOverflowing =
                          textPainter.height > constraints.maxHeight;

                      // Calculate approximate line height
                      final lineHeight = lineMetrics.isNotEmpty
                          ? textPainter.height / lineMetrics.length
                          : textStyle.fontSize ?? 16.0;

                      return Container(
                        constraints: BoxConstraints(maxHeight: 0.4.sh),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Text(
                            message.getDisplayContent,
                            style: textStyle.copyWith(
                              decoration: TextDecoration.none,
                              color: isPreviewReply
                                  ? AppColors.grey8
                                  : isReply
                                      ? AppColors.text2
                                      : isMine
                                          ? AppColors.text1
                                          : AppColors.text2,
                            ),
                            maxLines: isOverflowing
                                ? (constraints.maxHeight ~/ lineHeight)
                                    .clamp(1, 10)
                                : null,
                            overflow:
                                isOverflowing ? TextOverflow.ellipsis : null,
                          ),
                        ),
                      );
                    },
                  )
                : Text(
                    message.content,
                    overflow: isTextEllipsis
                        ? TextOverflow.ellipsis
                        : TextOverflow.clip,

                    // style: AppTextStyles.s14w400.toColor(
                    //   isPreviewReply
                    //       ? AppColors.grey8
                    //       : isReply
                    //           ? AppColors.text2
                    //           : isMine
                    //               ? AppColors.text1
                    //               : AppColors.text2,
                    // ),
                    style: AppTextStyles.s16w400.copyWith(
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
      ),
    );
  }

  /// Widget use for rendering content of message with type is hypertext
  Widget contentHyperText(
      BuildContext context, String content, Map<String, int> mentionUserIdMap) {
    return StyledText(
      text: content,
      overflow: isTextEllipsis ? TextOverflow.ellipsis : TextOverflow.clip,
      style: AppTextStyles.s16w400.toColor(
        isMine ? AppColors.text1 : AppColors.text2,
      ),
      maxLines: maxLines,
      tags: {
        AppConstants.mentionTag: StyledTextActionTag(
          (mention, _) => onMentionPressed(mention, mentionUserIdMap),
          style: AppTextStyles.s16w400.copyWith(
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
              final List<String> parts = hyper.split('/');

              final String idMeeting = parts[3];

              Get.find<ChatHubController>()
                  .createOrJoinCallJitsi(idMeeting, ' ');
            } else {
              IntentUtils.openBrowserURL(url: hyper);
            }
          },
          style: AppTextStyles.s16w400.copyWith(
            color: isPreviewReply
                ? AppColors.grey8
                : isMine
                    ? Colors.white
                    : AppColors.blue10,
            decoration: TextDecoration.underline,
            decorationColor: isPreviewReply
                ? AppColors.grey8
                : isMine
                    ? Colors.white
                    : AppColors.blue10,
          ),
        ),
      },
    );
  }
}
