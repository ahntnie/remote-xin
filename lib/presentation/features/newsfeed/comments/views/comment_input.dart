import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/exceptions/validation_exception.dart';
import '../../../../../core/extensions/all.dart';
import '../../../../../core/helpers/media_helper.dart';
import '../../../../../core/utils/view_util.dart';
import '../../../../common_widgets/all.dart';
import '../../../../common_widgets/app_blurry_container.dart';
import '../../../../resource/resource.dart';
import '../controllers/comment_input_controller.dart';

class CommentInput extends GetView<CommentInputController> {
  const CommentInput({Key? key}) : super(key: key);

  void _showMediaPicker() {
    MediaHelper.pickMedia().then((media) {
      if (media != null) {
        controller.attachMedia(media);
      }
    }).catchError(
      (error) {
        if (error is ValidationException) {
          ViewUtil.showToast(
            title: Get.context!.l10n.error__file_is_too_large_title,
            message: Get.context!.l10n.error__file_is_too_large_message,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          Container(
            color: AppColors.label,
            width: double.infinity,
            height: 1,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AppSpacing.gapW12,
              // _buildAvatar(),
              // AppSpacing.gapW12,
              Expanded(child: _buildTextField(context)),
              _buildSendButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return AppCircleAvatar(
      size: Sizes.s48,
      url: controller.currentUser.avatarPath ?? '',
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          if (controller.replyToComment != null ||
              controller.toEditComment != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.s20,
              ),
              child: _buildReplyOrEditContainer(context),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.pickedMedia != null)
                Padding(
                  padding: AppSpacing.edgeInsetsOnlyBottom12,
                  child: AppMediaPreview(
                    media: controller.pickedMedia!,
                    onRemove: controller.removeMedia,
                  ),
                ),
              AppTextField(
                controller: controller.textEditingController,
                focusNode: controller.focusNode,
                borderRadius: Sizes.s32,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Sizes.s20,
                  vertical: Sizes.s8,
                ),
                maxLines: 5,
                minLines: 1,
                hintText: context.l10n.comments__input_hint,
                hintStyle:
                    AppTextStyles.s14w400.copyWith(color: AppColors.zambezi),
                onChanged: controller.onChanged,
                suffixIcon: AppIcon(
                  icon: AppIcons.gallery,
                  onTap: _showMediaPicker,
                  color: AppColors.text2,
                ),
                border: InputBorder.none,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Obx(
      () => controller.textComment.isEmpty && controller.pickedMedia == null
          ? AppSpacing.gapW12
          : AppIcon(
              icon: AppIcons.send,
              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
              color: AppColors.text2,
              onTap: controller.postComment,
            ),
    );
  }

  Widget _buildReplyOrEditContainer(BuildContext context) {
    final action = controller.toEditComment != null
        ? context.l10n.comments__edit_comment_label
        : context.l10n.comments__replying_to;

    final value = controller.toEditComment != null
        ? controller.toEditComment!.comment
        : controller.replyToComment!.authorName;

    return AppBlurryContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.s12,
        vertical: Sizes.s8,
      ),
      child: Row(
        children: [
          Text(
            action,
            style: AppTextStyles.s12w400,
          ),
          AppSpacing.gapW4,
          Text(
            value,
            style: AppTextStyles.s12w600,
          ),
          const Spacer(),
          AppIcon(
            icon: AppIcons.close,
            size: Sizes.s16,
            onTap: () => controller.toEditComment != null
                ? controller.setEditComment(null)
                : controller.setReplyToComment(null),
          ),
        ],
      ),
    ).paddingSymmetric(vertical: Sizes.s8);
  }
}
