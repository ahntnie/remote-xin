part of 'conversation_details_view.dart';

class _GroupChatDetails extends StatelessWidget {
  final ConversationDetailsController controller;

  const _GroupChatDetails({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        if (controller.isConversationUpdated) {
          Get.find<ChatHubController>()
              .conversationUpdated(controller.conversation);
        }
      },
      child: CommonScaffold(
        backgroundGradientColor: AppColors.background6,
        hideKeyboardWhenTouchOutside: true,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          padding: AppSpacing.edgeInsetsH20,
          child: Column(
            children: [
              _buildConversationInfo(context),
              AppSpacing.gapH16,
              ActionChatDetails(
                controller: controller,
                isGroup: controller.conversation.isGroup,
              ),
              AppSpacing.gapH20,
              _buildOtherSettings(context),
              AppSpacing.gapH20,
              _buildPrivacyAndSupport(context),
              AppSpacing.gapH16,
              ConversationSharedLink(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  CommonAppBar _buildAppBar(BuildContext context) {
    return CommonAppBar(
      titleType: AppBarTitle.none,
      leadingIconColor: AppColors.text2,
      actions: [_buildSaveChangesButton(context)],
    );
  }

  Widget _buildSaveChangesButton(BuildContext context) {
    return Obx(
      () => controller.isEdited
          ? TextButton(
              onPressed: () {
                ViewUtil.hideKeyboard(context);
                controller.saveChanges();
              },
              child: Text(
                context.l10n.button__save,
                style: AppTextStyles.s16w400.text4Color,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildConversationInfo(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          _buildAvatar(context),
          AppSpacing.gapH8,
          _buildConversationTitle(),
          if (!controller.isCreatorOrAdmin) AppSpacing.gapH8,
          Text(
            '${controller.conversation.memberIds.length} ${context.l10n.conversation_details__members}',
            style: AppTextStyles.s14w400.text4Color,
          ),
          if (controller.isCreatorOrAdmin)
            Text(
              context.l10n.text_rename_group,
              style: AppTextStyles.s14w400.toColor(AppColors.blue10),
            ).paddingOnly(top: 4).clickable(() => Get.to(
                () => EditInfoGroupChat(
                      controller: controller,
                    ),
                transition: Transition.cupertino)),
        ],
      ),
    );
  }

  Widget _buildConversationTitle() {
    if (!controller.isCreatorOrAdmin) {
      return Text(
        controller.conversation.title(),
        style: AppTextStyles.s18w500.text2Color,
      );
    }
    return Text(
      controller.conversationNameController.text,
      style: AppTextStyles.s18w500.text2Color,
    );
    // return TextField(
    //   controller: controller.conversationNameController,
    //   onChanged: (_) => controller.validateIsEdited(),
    //   textAlign: TextAlign.center,
    //   style: AppTextStyles.s18w500.text2Color,
    //   textCapitalization: TextCapitalization.sentences,
    //   decoration: const InputDecoration(border: InputBorder.none),
    //   cursorColor: AppColors.text2,
    // );
  }

  Widget _buildAvatar(BuildContext context) {
    if (!controller.isCreatorOrAdmin) {
      return AppCircleAvatar(
        url: controller.conversation.avatarUrl ?? '',
        size: 100,
      ).clickable(() {
        if (controller.conversation.avatarUrl == null ||
            controller.conversation.avatarUrl == '' ||
            controller.conversation.avatarUrl == 'null') {
          return;
        }
        _buildShowDialogAvatarUrl(
          avatarPath: controller.conversation.avatarUrl ?? '',
          context: context,
        );
      });
    }

    return Stack(
      children: [
        Obx(
          () => controller.newAvatar == null
              ? AppCircleAvatar(
                  url: controller.conversation.avatarUrl ?? '',
                  size: 100,
                ).clickable(() {
                  if (controller.conversation.avatarUrl == null ||
                      controller.conversation.avatarUrl == '' ||
                      controller.conversation.avatarUrl == 'null') {
                    return;
                  }
                  _buildShowDialogAvatarUrl(
                    avatarPath: controller.conversation.avatarUrl ?? '',
                    context: context,
                  );
                })
              : Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: FileImage(controller.newAvatar!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ).clickable(() {
                  _buildShowDialogAvatarLocal(
                    file: controller.newAvatar!,
                    context: context,
                  );
                }),
        ),
        // Positioned(
        //   bottom: 0,
        //   right: 0,
        //   child: Container(
        //     width: Sizes.s36,
        //     height: Sizes.s36,
        //     decoration: const BoxDecoration(
        //         shape: BoxShape.circle, color: AppColors.blue10),
        //     child: Center(
        //       child: AppIcon(
        //         icon: AppIcons.cameraChange,
        //       ),
        //     ),
        //   ).clickable(() {
        //     controller.pickImage();
        //   }),
        // ),
      ],
    );
  }

  void _buildShowDialogAvatarLocal({
    required BuildContext context,
    required File file,
  }) {
    Get.generalDialog(
      barrierColor: Colors.black87,
      pageBuilder: (context, animation, secondaryAnimation) {
        return DismissiblePage(
          onDismissed: () => Navigator.of(context).pop(),
          // Start of the optional properties
          isFullScreen: false,
          minRadius: 10,
          maxRadius: 10,
          dragSensitivity: 1.0,
          maxTransformValue: .8,
          direction: DismissiblePageDismissDirection.multi,
          // onDragStart: () {
          //   print('onDragStart');
          // },
          // onDragUpdate: (details) {
          //   print(details);
          // },
          dismissThresholds: const {
            DismissiblePageDismissDirection.vertical: .2,
          },
          minScale: .8,
          reverseDuration: const Duration(milliseconds: 250),
          // End of the optional properties
          child: PhotoViewGallery.builder(
            builder: (BuildContext context, int index) =>
                PhotoViewGalleryPageOptions(
              imageProvider: FileImage(file),
              maxScale: 4.0,
              minScale: PhotoViewComputedScale.contained,
            ),
            itemCount: 1,
            // loadingBuilder: (context, event) =>
            //     _imageGalleryLoadingBuilder(event),

            scrollPhysics: const ClampingScrollPhysics(),
          ),
        );
      },
    );
  }

  void _buildShowDialogAvatarUrl({
    required BuildContext context,
    required String avatarPath,
  }) {
    Get.generalDialog(
      barrierColor: Colors.black87,
      pageBuilder: (context, animation, secondaryAnimation) {
        return DismissiblePage(
          onDismissed: () => Navigator.of(context).pop(),
          // Start of the optional properties
          isFullScreen: false,
          minRadius: 10,
          maxRadius: 10,
          dragSensitivity: 1.0,
          maxTransformValue: .8,
          direction: DismissiblePageDismissDirection.multi,
          // onDragStart: () {
          //   print('onDragStart');
          // },
          // onDragUpdate: (details) {
          //   print(details);
          // },
          dismissThresholds: const {
            DismissiblePageDismissDirection.vertical: .2,
          },
          minScale: .8,
          reverseDuration: const Duration(milliseconds: 250),
          // End of the optional properties
          child: PhotoViewGallery.builder(
            builder: (BuildContext context, int index) =>
                PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(avatarPath),
              maxScale: 4.0,
              minScale: PhotoViewComputedScale.contained,
            ),
            itemCount: 1,
            // loadingBuilder: (context, event) =>
            //     _imageGalleryLoadingBuilder(event),

            scrollPhysics: const ClampingScrollPhysics(),
          ),
        );
      },
    );
  }

  Widget _buildDivider() =>
      const Divider(height: Sizes.s24, color: Color(0xffdbdbdb));

  Widget buildContainerGroupItem(Widget child) => Container(
      padding: AppSpacing.edgeInsetsAll16,
      width: 0.85.sw,
      decoration: BoxDecoration(
        color: AppColors.grey11,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child);

  Widget builditemSetting(
          Object icon, Color color, String title, Function() onTap) =>
      Row(
        children: [
          AppIcon(
            icon: icon,
            color: color,
          ),
          AppSpacing.gapW12,
          Text(
            title,
            style: AppTextStyles.s16w600.toColor(color),
          ),
          const Spacer(),
          if (icon != AppIcons.trashMessage)
            AppIcon(
              icon: AppIcons.arrowRight,
              color: AppColors.text2,
            )
        ],
      ).clickable(() {
        onTap();
      });

  Widget _buildOtherSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.conversation_details__other_settings,
            style: AppTextStyles.s16w700.copyWith(color: AppColors.text2)),
        AppSpacing.gapH8,
        buildContainerGroupItem(Column(
          children: [
            builditemSetting(
              AppIcons.mediaLibrary,
              AppColors.text2,
              context.l10n.conversation_details__chat_resource,
              controller.goToChatResources,
            ),
            _buildDivider(),
            builditemSetting(
              Assets.icons.members,
              AppColors.text2,
              context.l10n.conversation_details__members,
              controller.goToChatMembers,
            ),
          ],
        ))
      ],
    );
    // return SettingGroupWidget(
    //   groupName: context.l10n.conversation_details__other_settings,
    //   children: [
    //     SettingItem(
    //       icon: AppIcons.media,
    //       title: context.l10n.conversation_details__chat_resource,
    //       onTap: controller.goToChatResources,
    //     ),
    //     SettingItem(
    //       icon: AppIcons.user,
    //       title: context.l10n.conversation_details__members,
    //       onTap: controller.goToChatMembers,
    //     ),
    //     SettingItem(
    //       icon: AppIcons.logout,
    //       title: context.l10n.conversation_details__leave_group,
    //       onTap: () => onLeaveGroup(context),
    //     ),
    //   ],
    // );
  }

  Widget _buildPrivacyAndSupport(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.conversation_details__privacy_and_support,
            style: AppTextStyles.s16w700.copyWith(color: AppColors.text2)),
        AppSpacing.gapH8,
        buildContainerGroupItem(
          Column(
            children: [
              builditemSetting(
                Assets.icons.leaveGroup,
                AppColors.text2,
                context.l10n.conversation_details__leave_group,
                () => onLeaveGroup(context),
              ),
              _buildDivider(),
              builditemSetting(
                AppIcons.trashMessage,
                AppColors.negative,
                context.l10n.conversation_details__delete_chat,
                () => controller.onDeleteChat(context),
              ),
              _buildDivider(),
              builditemSetting(
                Icons.archive_rounded,
                AppColors.negative,
                'Lưu trữ tin nhắn',
                () => {},
              ),
            ],
          ),
        )
      ],
    );
    // return SettingGroupWidget(
    //   groupName: context.l10n.conversation_details__privacy_and_support,
    //   children: [
    //     if (controller.isCreatorOrAdmin)
    //       SettingItem(
    //         icon: AppIcons.delete,
    //         title: context.l10n.conversation_details__delete_chat,
    //         onTap: () => controller.onDeleteChat(context),
    //       ),
    //   ],
    // );
  }

  void onLeaveGroup(BuildContext context) {
    ViewUtil.showAppCupertinoAlertDialog(
      title: context.l10n.conversation_details__leave_group,
      message: context.l10n.conversation_details__leave_group_message,
      negativeText: context.l10n.button__cancel,
      positiveText: context.l10n.button__confirm,
      onPositivePressed: () {
        controller.onLeaveGroupChat();
      },
    );
  }
}
