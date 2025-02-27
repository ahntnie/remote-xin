import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';
import '../../../../all.dart';

class EditInfoGroupChat extends StatefulWidget {
  final ConversationDetailsController controller;
  const EditInfoGroupChat({
    required this.controller,
    super.key,
  });

  @override
  State<EditInfoGroupChat> createState() => _EditInfoGroupChatState();
}

class _EditInfoGroupChatState extends State<EditInfoGroupChat> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        titleType: AppBarTitle.none,
        actions: [
          Obx(
            () => widget.controller.isEdited
                ? TextButton(
                    onPressed: () {
                      ViewUtil.hideKeyboard(context);
                      widget.controller.saveChanges();
                      Get.back();
                    },
                    child: Text(
                      context.l10n.button__save,
                      style: AppTextStyles.s16w400.toColor(AppColors.blue10),
                    ),
                  )
                : const SizedBox.shrink(),
          )
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => widget.controller.newAvatar == null
                ? AppCircleAvatar(
                    url: widget.controller.conversation.avatarUrl ?? '',
                    size: 100,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: FileImage(widget.controller.newAvatar!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          AppSpacing.gapH8,
          Text(
            context.l10n.text_rename_group,
            style: AppTextStyles.s16w500.toColor(AppColors.blue10),
          ).clickable(() => widget.controller.pickImage()),
          AppSpacing.gapH12,
          Container(
            color: AppColors.grey11,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller.conversationNameController,
                    onChanged: (_) => widget.controller.validateIsEdited(),
                    style: AppTextStyles.s18w500.text2Color,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                        hintText: context.l10n.text_name_group,
                        hintStyle: AppTextStyles.s18w500.subText2Color,
                        border: InputBorder.none),
                    cursorColor: AppColors.text2,
                  ),
                ),
                AppIcon(
                  icon: Assets.icons.closeCircle,
                  color: Colors.black,
                  onTap: () =>
                      widget.controller.conversationNameController.clear(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
