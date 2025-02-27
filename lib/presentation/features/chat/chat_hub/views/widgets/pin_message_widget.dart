import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';
import '../../controllers/pin_message_controller.dart';

class PinMessageWidget extends StatefulWidget {
  final Conversation conversation;

  const PinMessageWidget({
    required this.conversation,
    super.key,
  });

  @override
  State<PinMessageWidget> createState() => _PinMessageWidgetState();
}

class _PinMessageWidgetState extends State<PinMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: PinMessageController(widget.conversation),
      builder: (controller) => Obx(
        () {
          const currentIndex = -1;
          String label = '';
          if (controller.pinnedMessages.isEmpty) {
            return AppSpacing.emptyBox;
          } else {
            var lastMessage = controller.pinnedMessages.last;
            final currentIndex = controller.currentReplyIndex.value;
            try {
              if (currentIndex != -1) {
                lastMessage = controller.pinnedMessages[currentIndex];
                if (controller.pinnedMessages.length - 1 - currentIndex > 0) {
                  label =
                      '#${controller.pinnedMessages.length - 1 - currentIndex}';
                }
              }
            } catch (e) {
              LogUtil.e(e);
            }

            return Container(
              height: 48 + Sizes.s8.h * 2,
              decoration: BoxDecoration(
                color: AppColors.grey6,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.text2.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 3), // // changes position of shadow
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: Sizes.s20.w, vertical: Sizes.s8.h),
              child: GestureDetector(
                onTap: () => controller.onMessageClick(lastMessage),
                behavior: HitTestBehavior.translucent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 2,
                      child: ListView.builder(
                        controller: controller.scrollController,
                        itemCount: controller.pinnedMessages.length,
                        itemBuilder: (context, index) {
                          // Calculate container height based on length conditions
                          double containerHeight;
                          if (controller.pinnedMessages.length == 1) {
                            containerHeight = 50; // Full height
                          } else if (controller.pinnedMessages.length == 2) {
                            containerHeight = 50 / 2; // Half height
                          } else {
                            containerHeight = 50 / 3;
                          }

                          return Container(
                            height: containerHeight,
                            width: 8,
                            decoration: BoxDecoration(
                              color: currentIndex == index
                                  ? AppColors.green3
                                  : AppColors.green3.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ).marginOnly(bottom: 2);
                        },
                      ),
                    ),

                    // Container(
                    //   color: AppColors.green3,
                    //   width: 2,
                    // ),
                    AppSpacing.gapW8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${context.l10n.conversation__pinned_message} $label',
                            style: AppTextStyles.s16w500.copyWith(
                              color: AppColors.blue10,
                            ),
                          ),
                          Text(
                            message(
                              context,
                              lastMessage,
                            ),
                            style: AppTextStyles.s14w600.copyWith(
                              color: AppColors.text2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.gapW24,
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: InkWell(
                        onTap: controller.showListPinnedMessages,
                        child: const AppIcon(
                          icon: Icons.arrow_drop_down_circle_outlined,
                          color: AppColors.grey10,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String message(BuildContext context, Message message) {
    final l10n = context.l10n;

    return switch (message.type) {
      MessageType.text => message.content,
      MessageType.hyperText => message.contentWithoutFormat,
      MessageType.image => l10n.conversation__pinned_image,
      MessageType.video => l10n.conversation__pinned_video,
      MessageType.audio => l10n.conversation__pinned_audio,
      MessageType.call => l10n.conversation__pinned_call,
      MessageType.file => l10n.conversation__pinned_file,
      MessageType.post => l10n.conversation__pinned_post,
      MessageType.sticker => l10n.conversation__pinned_sticker,
      MessageType.system => context.l10n.chat__sent_system_message,
    };
  }
}
