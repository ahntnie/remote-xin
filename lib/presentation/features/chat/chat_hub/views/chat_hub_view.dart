import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/conversation.dart';
import '../../../../../models/message.dart';
import '../../../../../models/user.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../common_widgets/anchor_scroll/all.dart';
import '../../../../resource/resource.dart';
import '../../../../routing/routers/app_pages.dart';
import '../../../call/views/widgets/dialog_choose_language.dart';
import '../../../search_user/views/search_user_bottom_sheet.dart';
import '../../conversation_details/controllers/conversation_details_controller.dart';
import '../../conversation_details/views/widgets/mute_widget.dart';
import '../controllers/chat_hub_controller.dart';
import '../controllers/chat_input_controller.dart';
import 'widgets/all.dart';
import 'widgets/pin_message_widget.dart';

class ChatHubView extends BaseView<ChatHubController> {
  const ChatHubView({super.key});

  @override
  bool get allowLoadingIndicator => true;

  void _goToChatDetails() {
    if (controller.conversation.isBlocked || controller.conversation.isLocked) {
      return;
    }

    Get.toNamed(
      Routes.conversationDetails,
      arguments: ConversationDetailsArguments(
        conversation: controller.conversation,
      ),
    )?.then(
      (updatedConversation) {
        if (updatedConversation != null &&
            updatedConversation is Conversation) {
          controller.conversationUpdated(updatedConversation);
        }
      },
    );
  }

  Widget _buildSelectMultiMessageMode(BuildContext context) {
    return Container(
      height: 0.1.sh,
      width: 1.sw,
      color: AppColors.backgroundPinMessage.withOpacity(0.5),
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
      child: Row(
        children: [
          Obx(
            () => controller.isShowDelete.value
                ? AppIcon(
                    icon: AppIcons.trashMessage,
                    color: AppColors.negative,
                    onTap: () {
                      ViewUtil.showAppCupertinoAlertDialog(
                        title: context.l10n.chat_hub__delete_message_title,
                        message: context.l10n.chat_hub__delete_message_content,
                        negativeText: context.l10n.button__cancel,
                        positiveText: context.l10n.button__delete,
                        onPositivePressed: () {
                          controller.deleteMultiMessage();
                        },
                      );
                    },
                  ).paddingOnly(right: 16)
                : const SizedBox(),
          ),
          AppIcon(
            icon: AppIcons.forward,
            color: AppColors.text2,
            onTap: () {
              ViewUtil.showBottomSheet<List<User>>(
                isScrollControlled: true,
                isFullScreen: true,
                child: CreateChatSearchUsersBottomSheet(
                  allowSelectMultiple: false,
                  title: context.l10n.chat__forward_to,
                  hintText: context.l10n.global__search,
                ),
              ).then(
                (selectedUsers) {
                  if (selectedUsers != null) {
                    controller.forwardMultiMessage(selectedUsers.first);
                  }
                },
              );
            },
          ),
          const Spacer(),
          Text(
            '${controller.listMessageSelected.length}  ${context.l10n.selected}',
            style: AppTextStyles.s16w600
                .copyWith(color: AppColors.titlePinMessage),
          ),
          const Spacer(),
          AppIcon(
            padding: AppSpacing.edgeInsetsAll8,
            icon: AppIcons.close,
            color: AppColors.text2,
            onTap: () {
              controller.isSelectMode.value = false;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ViewUtil.hideKeyboard(context);
        Get.find<ChatInputController>().stipop.hide();
      },
      child: Obx(
        () => CommonScaffold(
          appBar: controller.isSelectMode.value
              ? PreferredSize(
                  preferredSize: Size.fromHeight(0.1.sh),
                  child: _buildSelectMultiMessageMode(context))
              : _buildAppBar() as PreferredSizeWidget,
          backgroundGradientColor: AppColors.background6,
          body: Column(
            children: [
              Obx(
                () => controller.isConversationInitiated
                    ? PinMessageWidget(
                        conversation: controller.conversation,
                      )
                    : AppSpacing.emptyBox,
              ),
              controller.arguments.isBot == false
                  ? _buildTranslateWidget(context)
                  : const SizedBox(),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 0.059.sh),
                            child: _buildMessagesList(),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: _buildChatInput(),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 0,
                      child: Obx(
                        () => controller.showButtonScrollDown
                            ? FloatingActionButton(
                                onPressed: controller.scrollToBottom,
                                backgroundColor: AppColors.pacificBlue,
                                mini: true,
                                child: const Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: AppColors.white,
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapH8,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: AppSpacing.edgeInsetsH20,
      child: Divider(color: AppColors.stoke, thickness: 0.5, height: 1),
    );
  }

  CommonAppBar _buildAppBar() {
    return CommonAppBar(
      backgroundColor: Colors.white,
      titleWidget: Obx(() {
        if (!controller.isConversationInitiated) {
          return AppSpacing.emptyBox;
        }

        return Transform.translate(
          offset: const Offset(-20, 0),
          child: ListTile(
            leading: AppCircleAvatar(
              url: controller.conversation.avatarUrl ?? '',
            ),
            title: Obx(
              () => MuteWidget(
                isMuted: controller.conversation.isMuted == true,
                child: !controller.conversation.isGroup
                    ? ContactDisplayNameText(
                        user: controller.conversation.chatPartner()!,
                        style: AppTextStyles.s16w700.text2Color,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        controller.conversation.title(),
                        style: AppTextStyles.s16w700.text2Color,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
            // add isOnline if is private chat
            subtitle: _buildOnlineStatus(),
            onTap: controller.conversation.isBlocked ||
                    controller.conversation.isLocked
                ? null
                : _goToChatDetails,
          ),
        );
      }),
      actions: !controller.isConversationInitiated
          ? []
          : [
              if (!controller.conversation.isGroup &&
                  controller.arguments.isBot == false) ...[
                AppIcon(
                  padding: AppSpacing.edgeInsetsAll8,
                  color: AppColors.text2,
                  icon: Assets.icons.callTranslate,
                ).clickable(() {
                  showAlertDialogChooseLanguage(
                      currentUser.talkLanguage!,
                      Get.context!,
                      currentUser.id,
                      currentUser.lastName,
                      currentUser.firstName,
                      currentUser.phone ?? '',
                      currentUser.avatarPath ?? '',
                      currentUser.nickname ?? '',
                      currentUser.email ?? '', () {
                    controller.onCallTranslateTap();
                  }, currentUser);
                }),
                // AppIcon(
                //   padding: AppSpacing.edgeInsetsAll8,
                //   icon: AppIcons.callAudio,
                //   color: AppColors.text2,
                //   onTap: controller.onCallVoiceTap,
                // ),
                if (controller.arguments.isBot == false)
                  AppIcon(
                    padding: AppSpacing.edgeInsetsAll8,
                    icon: AppIcons.videoOn,
                    color: AppColors.text2,
                    onTap: controller.onCallVideoTap,
                  ),
              ],
              if (controller.conversation.isGroup &&
                  controller.isCreatorOrAdmin &&
                  controller.arguments.isBot == false)
                AppIcon(
                  padding: AppSpacing.edgeInsetsAll8,
                  icon: AppIcons.videoOn,
                  color: AppColors.text2,
                  onTap: controller.onCallVideoGroupTap,
                ),
              AppIcon(
                padding: AppSpacing.edgeInsetsAll8.copyWith(right: 0),
                icon: AppIcons.infoOutline,
                color: AppColors.text2,
                onTap: _goToChatDetails,
              ),
            ],
      onLeadingPressed: controller.leadingIconOnTap,
    );
  }

  Widget _buildMessagesList() {
    return CommonPagedListView<Message>(
      scrollController: controller.anchorScrollController,
      pagingController: controller.pagingController,
      padding: AppSpacing.edgeInsetsH20,
      cacheExtent: 5000,
      noMoreItemsIndicator: const SizedBox(),
      noItemsFoundIndicator: const SizedBox(),
      firstPageProgressIndicator: const SizedBox(),
      newPageProgressIndicator: const SizedBox(),
      // separatorBuilder: (context, index) => AppSpacing.gapH16,
      reverse: true,
      itemBuilder: (context, message, index) {
        final previousMessage =
            index + 1 < controller.pagingController.itemList!.length
                ? controller.pagingController.itemList![index + 1]
                : null;

        final nextMessage = index - 1 >= 0
            ? controller.pagingController.itemList![index - 1]
            : null;

        return Column(
          children: [
            AnchorItemWrapper(
              index: index,
              controller: controller.anchorScrollController,
              child: Obx(
                () => MessageItem(
                  key: ValueKey(message.id),
                  isMine: message.isMine(myId: controller.currentUser.id),
                  message: controller.isTranslateMessage.value &&
                          message.type == MessageType.text
                      ? message.copyWith(
                          content: controller.translateMessageMap[message.id])
                      : message,
                  previousMessage: previousMessage,
                  nextMessage: nextMessage,
                  isSelectMode: controller.isSelectMode.value,
                  isSelect: controller.listMessageSelected.contains(message),
                  currentUserId: controller.currentUser.id,
                  isAdmin: controller.conversation.isAdmin(currentUser.id),
                  onTap: () => controller.onMessageTap(message),
                  onPressedUserAvatar: () =>
                      controller.onUserAvatarTap(message),
                  members: controller.conversation.members,
                  isGroup: controller.conversation.isGroup,
                  onMentionPressed: controller.onMentionPressed,
                  onSelectMessage: (Message message) =>
                      controller.onSelectMessage(message),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: message.isMine(myId: controller.currentUser.id) &&
                    controller.indexLastSeen.value == index,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AppCircleAvatar(
                    url: controller.conversation.avatarUrl ?? '',
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildOnlineStatus() {
    return Obx(
      () => controller.conversation.isGroup
          ? Text(
              '${controller.conversation.memberIds.length.toString()} ${l10n.conversation_details__members}',
              style: AppTextStyles.s14w400.toColor(AppColors.subText2),
            )
          : Row(
              children: [
                controller.arguments.isBot
                    ? Text(
                        'bot',
                        style: AppTextStyles.s14w400.subText2Color,
                      )
                    : Text(
                        controller.isOnline
                            ? l10n.global__online
                            : l10n.global__offline,
                        style: AppTextStyles.s14w400.subText2Color,
                      ),
                if (controller.isOnline)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    height: 8,
                    width: 8,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xff52C91D)),
                  )
              ],
            ),
    );
  }

  Widget _buildChatInput() {
    return Obx(
      () => controller.isConversationInitiated
          ? !controller.conversation.isGroup &&
                  controller.conversation.isBlocked
              ? _buildBlockedConversationWidget()
              : controller.conversation.isLocked
                  ? AppSpacing.gapH32
                  : const ChatInput()
          : AppSpacing.gapH32,
    );
  }

  Widget _buildBlockedConversationWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: Sizes.s20,
        right: Sizes.s20,
        bottom: Sizes.s32,
        top: Sizes.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.zambezi.withOpacity(0.27),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 0.15.sw,
            height: 5,
            decoration: BoxDecoration(
                color: AppColors.grey10,
                borderRadius: BorderRadius.circular(100)),
          ),
          AppSpacing.gapH12,
          Text(
            controller.conversation.blockedByMe
                ? l10n.chat_hub__you_blocked
                : l10n.chat_hub__blocked_by_user,
            style: AppTextStyles.s14w400.toColor(AppColors.subText2),
          ),
          if (controller.conversation.blockedByMe)
            Padding(
              padding: AppSpacing.edgeInsetsOnlyTop16,
              child: AppButton.primary(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                label: l10n.chat_hub__unblock_btn,
                onPressed: controller.unblockUser,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTranslateWidget(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Container(
          width: 1.sw,
          color: AppColors.backgroundPinMessage.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: !controller.isTranslateMessage.value
              ? Center(
                  child: Text(
                  '${l10n.chat_hub__translate_to} ${languages[controller.translateLanguageMessageIndex.value]['title']}',
                  style: AppTextStyles.s16w600
                      .copyWith(color: AppColors.titlePinMessage),
                )).clickable(() {
                  controller.handleTranslateMessage(true);
                })
              : Center(
                  child: Text(
                  l10n.chat_hub__translate_back,
                  style: AppTextStyles.s16w600
                      .copyWith(color: AppColors.titlePinMessage),
                )).clickable(() {
                  controller.handleTranslateMessage(false);
                }),
        ),
        Positioned(
          right: 20,
          child: _buildIconMoreTranslate(context),
        )
      ],
    );
  }

  Widget _buildIconMoreTranslate(BuildContext context) => PopupMenuButton<int>(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        position: PopupMenuPosition.under,
        onSelected: (value) {},
        itemBuilder: (context) => [
          for (int i = 0; i < languages.length; i++) ...[
            PopupMenuItem<int>(
              value: 4,
              child: Row(
                children: [
                  Text(
                    languages[i]['title'] ?? '',
                    style: AppTextStyles.s16Base.text2Color,
                  ),
                ],
              ),
              onTap: () {
                controller.updateTranslateLanguageMessage(i);
              },
            )
          ],
        ],
        child: Assets.icons.more.svg(color: AppColors.subTextConversationItem),
      );
}
