import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/all.dart';
import '../../../../../../repositories/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';
import '../../../../../routing/routing.dart';
import '../../../../all.dart';
import '../../../../search_user/all.dart';
import 'mute_conversation_action_widget.dart';

class ActionChatDetails extends StatelessWidget {
  final bool isGroup;
  final ConversationDetailsController controller;

  const ActionChatDetails({
    required this.controller,
    required this.isGroup,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isGroup) ...[
          Column(
            children: [
              GestureDetector(
                // onTap: controller.onCallVoiceClick,
                onTap: () async {
                  final UserRepository userRepository = Get.find();

                  final userPartner = await userRepository
                      .getUserById(controller.conversation.chatPartner()!.id);
                  // await Get.toNamed(
                  //   Routes.posterPersonal,
                  //   arguments: {
                  //     'user': userPartner,
                  //     'isChat': true,
                  //   },
                  // );
                  Get.toNamed(Routes.myProfile, arguments: {
                    'isMine': false,
                    'user': userPartner,
                    'isAddContact': Get.find<ConversationDetailsController>()
                        .userContactList
                        .isEmpty,
                  });
                },
                child: Container(
                  width: Sizes.s40,
                  height: Sizes.s40,
                  decoration: const BoxDecoration(
                    color: AppColors.grey6,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    icon: Assets.icons.personalPage,
                    color: AppColors.text2,
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ),
              AppSpacing.gapH4,
              Text(
                context.l10n.text_personal_page,
                style: AppTextStyles.s16w600.text2Color,
              )
            ],
          ),
          AppSpacing.gapW32,
          Column(
            children: [
              // GestureDetector(
              //   onTap: () => controller.onMuteConversation(Mu),
              //   child: Container(
              //     width: Sizes.s40,
              //     height: Sizes.s40,
              //     decoration: const BoxDecoration(
              //       color: AppColors.grey6,
              //       shape: BoxShape.circle,
              //     ),
              //     child: AppIcon(
              //       icon: AppIcons.bell,
              //       color: AppColors.text2,
              //       padding: const EdgeInsets.all(6),
              //     ),
              //   ),
              // ),
              MuteConversationActionWidget(controller: controller),
              AppSpacing.gapH4,
              Text(
                context.l10n.text_mute,
                style: AppTextStyles.s16w600.text2Color,
              )
            ],
          ),
        ],
        if (isGroup) ...[
          Column(
            children: [
              GestureDetector(
                onTap: () => onAddMember(context),
                child: Container(
                  width: Sizes.s40,
                  height: Sizes.s40,
                  decoration: const BoxDecoration(
                    color: AppColors.grey6,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    icon: Assets.icons.addUser,
                    color: AppColors.text2,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
              AppSpacing.gapH4,
              Text(
                context.l10n.contact__add,
                style: AppTextStyles.s16w600.text2Color,
              )
            ],
          ),
          AppSpacing.gapW32,
          Column(
            children: [
              // GestureDetector(
              //   onTap: () => controller.onMuteConversation,
              //   child: Container(
              //     width: Sizes.s40,
              //     height: Sizes.s40,
              //     decoration: const BoxDecoration(
              //       color: AppColors.grey6,
              //       shape: BoxShape.circle,
              //     ),
              //     child: AppIcon(
              //       icon: AppIcons.bell,
              //       color: AppColors.text2,
              //       padding: const EdgeInsets.all(6),
              //     ),
              //   ),
              // ),
              MuteConversationActionWidget(controller: controller),
              AppSpacing.gapH4,
              Text(
                context.l10n.text_mute,
                style: AppTextStyles.s16w600.text2Color,
              )
            ],
          ),
        ],
        // MuteConversationActionWidget(controller: controller),
      ],
    );
  }

  void onAddMember(BuildContext context) {
    ViewUtil.showBottomSheet<List<User>>(
      isScrollControlled: true,
      isFullScreen: true,
      child: CreateChatSearchUsersBottomSheet(
        allowSelectMultiple: false,
        title: context.l10n.conversation_members__add_member,
        hintText: context.l10n.global__search,
      ),
    ).then(
      (selectedUsers) {
        if (selectedUsers != null) {
          controller.addMember(selectedUsers.first);
        }
      },
    );
  }
}
