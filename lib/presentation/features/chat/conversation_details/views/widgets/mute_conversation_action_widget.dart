import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../models/enums/mute_conversation_option_enum.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';
import '../../../../all.dart';

class MuteConversationActionWidget extends StatefulWidget {
  final ConversationDetailsController controller;

  const MuteConversationActionWidget({required this.controller, super.key});

  @override
  State<MuteConversationActionWidget> createState() =>
      _MuteConversationActionWidgetState();
}

class _MuteConversationActionWidgetState
    extends State<MuteConversationActionWidget> {
  MenuController menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onCallVideoClick,
      child: Container(
        width: Sizes.s40,
        height: Sizes.s40,
        decoration: const BoxDecoration(
          color: AppColors.grey6,
          shape: BoxShape.circle,
        ),
        child: MenuAnchor(
          controller: menuController,
          style: MenuStyle(
            backgroundColor:
                WidgetStateColor.resolveWith((states) => AppColors.white),
          ),
          menuChildren: MuteConversationOption.values
              .map(
                (e) => MenuItemButton(
                  child: Text(
                    e.labelName(l10n),
                    style: AppTextStyles.s14w600.copyWith(
                      color: AppColors.text2,
                    ),
                  ),
                  onPressed: () {
                    widget.controller.onMuteConversation(e);
                  },
                ),
              )
              .toList(),
          child: AppIcon(
            icon: widget.controller.conversation.isMuted == true
                ? Assets.icons.muteNoti
                : Assets.icons.notification,
            color: AppColors.text2,
            padding: const EdgeInsets.all(Sizes.s8),
          ),
        ),
      ),
    );
  }

  void onCallVideoClick() {
    if (widget.controller.conversation.isMuted == false) {
      menuController.open();
    } else {
      widget.controller.onUnMuteConversation();
    }
  }
}
