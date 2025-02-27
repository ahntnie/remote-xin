import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../models/conversation.dart';
import '../../../../../../../models/message.dart';
import '../../../../../../common_widgets/circle_avatar.dart';
import '../../../../../../resource/styles/gaps.dart';
import 'message/_message_item.dart';

class PreviewMessages extends StatelessWidget {
  const PreviewMessages({
    required this.messages,
    required this.conversation,
    required this.currentUserId,
    required this.indexLastSeen,
    super.key,
  });
  final List<Message> messages;
  final Conversation conversation;
  final int currentUserId;
  final int indexLastSeen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      constraints: BoxConstraints(maxHeight: 0.65.sh),
      child: IgnorePointer(
        child: ListView.builder(
          padding: AppSpacing.edgeInsetsAll20,
          shrinkWrap: true,
          // separatorBuilder: (context, index) => AppSpacing.gapH16,
          reverse: true,
          itemCount: messages.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final message = messages[index];
            final previousMessage =
                index + 1 < messages.length ? messages[index + 1] : null;
            final nextMessage = index - 1 >= 0 ? messages[index - 1] : null;
            return Column(
              children: [
                PreviewMessageItem(
                  key: ValueKey(message.id),
                  isMine: message.isMine(myId: currentUserId),
                  message: message,
                  previousMessage: previousMessage,
                  nextMessage: nextMessage,
                  currentUserId: currentUserId,
                  isAdmin: conversation.isAdmin(
                    currentUserId,
                  ),
                  onTap: () => {},
                  onPressedUserAvatar: () => {},
                  members: conversation.members,
                  isGroup: conversation.isGroup,
                  onMentionPressed:
                      (String? mention, Map<String, int> mentionUserIdMap) {},
                  conversation: conversation,
                ),
                if (message.isMine(myId: currentUserId) &&
                    indexLastSeen == index) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppCircleAvatar(
                      url: conversation.avatarUrl ?? '',
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
