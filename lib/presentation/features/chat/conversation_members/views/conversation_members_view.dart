import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

import '../../../../../core/all.dart';
import '../../../../../models/user.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../search_user/views/search_user_bottom_sheet.dart';
import '../controllers/conversation_members_controller.dart';

class ConversationMembersView extends BaseView<ConversationMembersController> {
  const ConversationMembersView({Key? key}) : super(key: key);

  void _onRemoveMember(BuildContext context, User member) {
    ViewUtil.showAppCupertinoAlertDialog(
      title: context.l10n.conversation_members__remove_confirm_title,
      message: context.l10n.conversation_members__remove_confirm_message,
      negativeText: context.l10n.button__cancel,
      positiveText: context.l10n.button__confirm,
      onPositivePressed: () => controller.removeMember(member),
    );
  }

  void _onAddMember(BuildContext context) {
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

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      applyAutoPaddingBottom: true,
      backgroundGradientColor: AppColors.background6,
      isRemoveBottomPadding: true,
      appBar: CommonAppBar(
        leadingIconColor: AppColors.text2,
        titleTextStyle: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
        centerTitle: false,
        onLeadingPressed: () => Get.back(result: controller.conversation),
        titleType: AppBarTitle.text,
        text: context.l10n.conversation_members__title,
        actions: [
          AppIcon(
            icon: Icons.add,
            color: AppColors.text2,
            onTap: () => _onAddMember(context),
          ),
        ],
        height: 56 + 60,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), // here the desired height
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: CustomSearchBar(
              hintText: context.l10n.global__search,
              onClear: () {
                controller.searchUserInGroup('');
              },
              onChanged: (value) {
                controller.searchUserInGroup(value);
              },
              searchController: controller.searchController,
              autofocus: false,
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
            ),
          ),
        ),
      ),
      body: Obx(
        () => controller.isLoadingMembers.value
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.blue10,
                ),
              )
            : SmoothListView.builder(
                duration: const Duration(milliseconds: 200),
                physics: const BouncingScrollPhysics(),
                padding: AppSpacing.edgeInsetsH20,
                itemCount: controller.searchMemberResult.length,
                itemBuilder: (context, index) {
                  final member = controller.searchMemberResult[index];

                  return _buildUserItem(
                    context,
                    member,
                  ).paddingOnly(
                      bottom: index != controller.searchMemberResult.length - 1
                          ? 8
                          : 0);
                },
              ),
      ),
    );
  }

  ListTile _buildUserItem(BuildContext context, User member) {
    final isYou = member.id == currentUser.id;

    return ListTile(
      splashColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      leading: AppCircleAvatar(
        url: member.avatarPath ?? '',
        size: 50,
      ),
      title: Row(
        children: [
          Expanded(
            child: isYou
                ? Text(
                    l10n.global__you,
                    style: AppTextStyles.s16w400.text2Color,
                  )
                : ContactDisplayNameText(
                    user: member,
                    style: AppTextStyles.s16w400.text2Color,
                  ),
          ),
          Transform.translate(
            offset: const Offset(30, 0),
            child: Text(
              member.id == controller.conversation.creatorId
                  ? context.l10n.conversation_members__creator
                  : controller.conversation.isAdmin(member.id)
                      ? context.l10n.conversation_members__admin
                      : '',
              style: AppTextStyles.s14w400.toColor(AppColors.blue10),
            ),
          ),
        ],
      ),
      // subtitle: member.id == controller.conversation.creatorId
      //     ? Text(context.l10n.conversation_members__creator)
      //     : controller.conversation.isAdmin(member.id)
      //         ? Text(context.l10n.conversation_members__admin)
      //         : null,
      trailing: _buildTrailing(context, member),
      onTap: () => _onTapMember(member),
    );
  }

  Widget _buildTrailing(BuildContext context, User member) {
    if (!controller.canRemoveMembers || member.id == currentUser.id) {
      return AppSpacing.emptyBox;
    }

    return AppIcon(
      icon: Icons.close,
      size: Sizes.s16,
      color: AppColors.negative,
      onTap: () => _onRemoveMember(context, member),
    );
  }

  void _onTapMember(User member) {
    if (member.isDeactivated() || member.id == currentUser.id) {
      return;
    }

    final actions = <ActionSheetItem>[];

    if (member.id != currentUser.id) {
      actions.add(
        ActionSheetItem(
          title: l10n.conversation_members__go_to_private_chat,
          onPressed: () => controller.goToPrivateChat(member),
        ),
      );
    }

    if (!(controller.conversation.isCreator(member.id) ||
        !controller.canRemoveMembers)) {
      final isAddAdmin = !controller.conversation.isAdmin(member.id);
      actions.add(
        ActionSheetItem(
          title: isAddAdmin
              ? l10n.conversation_members__promote_admin_label
              : l10n.conversation_members__remove_admin_label,
          onPressed: () => _onPromoteOrRemoveAdmin(member, isAddAdmin),
        ),
      );
    }

    if (actions.isEmpty) {
      return;
    }

    ViewUtil.showActionSheet(
      items: actions,
    );
  }

  void _onPromoteOrRemoveAdmin(User member, bool isAddAdmin) {
    late String? title;
    late String? message;

    if (isAddAdmin) {
      title = l10n.conversation_members__promote_confirm_title;
      message = l10n.conversation_members__promote_confirm_message;
    } else {
      title = l10n.conversation_members__remove_admin_confirm_title;
      message = l10n.conversation_members__remove_admin_confirm_message;
    }

    ViewUtil.showAppCupertinoAlertDialog(
      title: title,
      message: message,
      negativeText: l10n.button__cancel,
      positiveText: l10n.button__confirm,
      onPositivePressed: () =>
          controller.promoteOrRemoveAdmin(member, isAddAdmin),
    );
  }
}
