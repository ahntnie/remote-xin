import 'package:flutter/material.dart';

import '../../../../../core/all.dart';
import '../../../../../models/conversation.dart';
import '../../../../common_widgets/app_icon.dart';
import '../../../../common_widgets/check_box_button.dart';
import '../../../../common_widgets/circle_avatar.dart';
import '../../../../common_widgets/pooling/user_contact_name.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../../../resource/styles/gaps.dart';
import '../../../../resource/styles/text_styles.dart';
import '../../conversation_details/views/widgets/mute_widget.dart';

class SharedConversationItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final bool isSelectable;
  final bool isSelected;

  const SharedConversationItem({
    required this.conversation,
    required this.onTap,
    this.isSelected = false,
    this.isSelectable = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      splashColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      leading: _buildAvatar(),
      title: MuteWidget(
        isMuted: conversation.isMuted == true,
        child: _buildTitle(),
      ),
      trailing: isSelectable
          ? CheckBoxButton(
              value: isSelected,
              onChanged: (value) {
                onTap();
              },
            )
          : null,
    );
  }

  Widget _buildAvatar() {
    final child = AppCircleAvatar(
      url: conversation.avatarUrl ?? '',
    );

    if (conversation.isBlocked) {
      return Stack(
        children: [
          child,
          Positioned(
            bottom: 0,
            right: 0,
            child: AppIcon(
              icon: AppIcons.block,
              isCircle: true,
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.negative,
              color: AppColors.white,
              size: Sizes.s20,
            ),
          ),
        ],
      );
    }

    return child;
  }

  Widget _buildTitle() {
    if (!conversation.isGroup && conversation.chatPartner() != null) {
      return ContactDisplayNameText(
        user: conversation.chatPartner()!,
        style: AppTextStyles.s16w600.text2Color,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text(
      conversation.title(),
      style: AppTextStyles.s16w600.text2Color,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
