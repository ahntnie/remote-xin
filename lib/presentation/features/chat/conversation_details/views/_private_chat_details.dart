part of 'conversation_details_view.dart';

class _PrivateChatDetails extends StatelessWidget {
  final ConversationDetailsController controller;

  const _PrivateChatDetails({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CommonScaffold(
        hideKeyboardWhenTouchOutside: true,
        backgroundGradientColor: AppColors.background6,
        appBar: CommonAppBar(
          titleType: AppBarTitle.none,
          leadingIconColor: AppColors.text2,
          actions: [
            controller.getPhonePartner().isNotEmpty
                ? Text(
                    controller.userContactList.isEmpty
                        ? controller.l10n.contact__add
                        : controller.l10n.contact__edit,
                    style:
                        AppTextStyles.s14w600.copyWith(color: AppColors.text2),
                  ).clickable(() {
                    if (controller.userContactList.isEmpty) {
                      final UserContact userContact = UserContact(
                        contactFirstName: '',
                        contactLastName: '',
                        contactPhoneNumber: controller.getPhonePartner(),
                        user: controller.conversation.chatPartner(),
                      );
                      _onAddContact(userContact);
                    } else {
                      _onEditContact(controller.userContactList.first);
                    }
                  })
                : const SizedBox.shrink(),
          ],
        ),
        body: SingleChildScrollView(
          padding: AppSpacing.edgeInsetsH20,
          child: Column(
            children: [
              _buildConversationInfo(context),
              AppSpacing.gapH24,
              ActionChatDetails(
                controller: controller,
                isGroup: controller.conversation.isGroup,
              ),
              AppSpacing.gapH16,
              _buildPrivacyAndSupport(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationInfo(BuildContext context) {
    final controller = Get.find<ChatHubController>();
    return Column(
      children: [
        AppCircleAvatar(
          url: controller.conversation.avatarUrl ?? '',
          size: 100,
        ).clickable(() {
          _buildShowDialogAvatarUrl(
            context: context,
            avatarPath: controller.conversation.avatarUrl ?? '',
          );
        }),
        AppSpacing.gapH4,
        // Text(
        //   controller.conversation.title(),
        //   style: AppTextStyles.s26w600,
        // ),
        ContactDisplayNameText(
          user: controller.conversation.chatPartner()!,
          style: AppTextStyles.s22w700.text2Color,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        AppSpacing.gapH8,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.isOnline || controller.arguments.isBot
                  ? context.l10n.global__online
                  : context.l10n.global__offline,
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
        )
        // controller.getInfoPartner().isNotEmpty
        //     ? Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           AppSpacing.gapH8,
        //           Text(
        //             controller.getInfoPartner(),
        //             style: AppTextStyles.s14w400.subText2Color,
        //           ),
        //         ],
        //       )
        //     : const SizedBox.shrink(),
        // controller.getEmailPartner().isNotEmpty
        //     ? Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           AppSpacing.gapH4,
        //           Text(
        //             controller.getEmailPartner(),
        //             style: AppTextStyles.s14w400.subText2Color,
        //           ),
        //         ],
        //       )
        //     : const SizedBox.shrink(),
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

  Widget _buildDivider() =>
      const Divider(height: Sizes.s24, color: Color(0xffdbdbdb));

  Widget _buildPrivacyAndSupport(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.conversation_details__other_settings,
            style: AppTextStyles.s16w700.copyWith(color: AppColors.text2)),
        AppSpacing.gapH8,
        buildContainerGroupItem(Column(
          children: [
            builditemSetting(AppIcons.mediaLibrary, AppColors.text2,
                context.l10n.conversation_details__chat_resource, () {
              controller.goToChatResources();
            }),
            _buildDivider(),
            builditemSetting(AppIcons.userBlock, AppColors.text2,
                context.l10n.button__block_user, () {
              controller.onBlockChat(context);
            }),
            _buildDivider(),
            builditemSetting(
                Icons.archive, AppColors.text2, 'Lưu trữ tin nhắn', () => {}),
            _buildDivider(),
            builditemSetting(
              AppIcons.trashMessage,
              AppColors.negative,
              context.l10n.conversation_details__delete_chat,
              () => controller.onDeleteChat(context),
            ),
          ],
        )),
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
    //       icon: AppIcons.block,
    //       title: context.l10n.button__block_user,
    //       onTap: () => controller.onBlockChat(context),
    //     ),
    //     SettingItem(
    //       icon: AppIcons.delete,
    //       title: context.l10n.conversation_details__delete_chat,
    //       onTap: () => controller.onDeleteChat(context),
    //     ),
    //   ],
    // );
  }

  void _onEditContact(UserContact userContact) {
    // ViewUtil.showBottomSheet(
    //   child: ContactInfo(
    //     userContact: userContact,
    //     isEditContact: true,
    //     controller: controller,
    //   ),
    //   isScrollControlled: true,
    //   isFullScreen: true,
    // );
    Get.to(
        () => ContactInfo(
              userContact: userContact,
              controller: controller,
              isEditContact: true,
            ),
        transition: Transition.cupertino);
  }

  void _onAddContact(UserContact userContact) {
    // ViewUtil.showBottomSheet(
    //   child: ContactInfo(
    //     userContact: userContact,
    //     isAddContact: true,
    //     controller: controller,
    //   ),
    //   isScrollControlled: true,
    //   isFullScreen: true,
    // );
    Get.to(
        () => ContactInfo(
              userContact: userContact,
              controller: controller,
              isAddContact: true,
            ),
        transition: Transition.cupertino);
  }
}
