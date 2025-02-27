import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../all.dart';
import 'widgets/image_gallery_edit_post.dart';

class EditPostView extends BaseView<EditPostController> {
  const EditPostView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      hideKeyboardWhenTouchOutside: true,
      appBar: CommonAppBar(
        leadingIcon: LeadingIcon.close,
        onLeadingPressed: () {
          controller.clearPickedMedia();
          Get.back();
        },
        text: l10n.newsfeed__edit_post_title,
        titleType: AppBarTitle.text,
        titleTextStyle: AppTextStyles.s18w700.text2Color,
        centerTitle: false,
        actions: [
          Obx(
            () => Text(
              l10n.newsfeed__edit_post_update,
              style: AppTextStyles.s16w500.copyWith(
                color: (controller.attachments.value.isNotEmpty ||
                        controller.isHaveText.value)
                    ? AppColors.blue10
                    : AppColors.grey10,
                fontWeight: (controller.attachments.value.isNotEmpty ||
                        controller.isHaveText.value)
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ).clickable(() {
              controller.updatePost();
            }),
          ),
        ],
        leadingIconColor: AppColors.text2,
        bottom: PreferredSize(
            preferredSize: Size(1.sw, 10),
            child: const Divider(
              color: AppColors.grey6,
              height: 10,
            )),
      ),
      body: Obx(
        () => Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            AppSpacing.gapH24,
                            _buildUserPost(),
                            AppSpacing.gapH12,
                            _buildTextField().paddingOnly(bottom: Sizes.s20),
                          ],
                        ).paddingSymmetric(horizontal: Sizes.s20),
                      ),
                      // SliverToBoxAdapter(
                      //   child: _buildImageGalleryOld(),
                      // ),
                      SliverToBoxAdapter(
                        child: _buildImageGallery(),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: Sizes.s20,
                        ),
                      ),
                    ],
                  ),
                ),
                SlidingUpPanel(
                  borderRadius: BorderRadius.circular(Sizes.s20),
                  maxHeight: 0.2.sh,
                  minHeight: 0.09.sh,
                  color: Colors.transparent,
                  defaultPanelState: PanelState.OPEN,
                  controller: controller.slidingUpPanelController,
                  panel: const PostInputResourceView(),
                  collapsed: const PostInputResourceCollapsedView(),
                ),
              ],
            ),
            controller.postInputResourceController.isLoadingResource.value
                ? const AppDefaultLoading(
                    color: AppColors.pacificBlue,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return ImageGalleryEditPost(controller: controller);
  }

  Widget _buildImageGalleryOld() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - Sizes.s60;

        return Wrap(
          alignment: WrapAlignment.center,
          runSpacing: Sizes.s20,
          spacing: Sizes.s20,
          children: controller.attachments.map((e) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                if (e is PickedMedia && e.type == MediaAttachmentType.video)
                  SizedBox(
                    width:
                        controller.attachments.length > 1 ? width / 2 : width,
                    height: controller.attachments.length > 1 ? 164.h : 338.h,
                    child: AppVideoPlayer(
                      e.file.path,
                      isFile: true,
                      borderRadius: BorderRadius.circular(Sizes.s20),
                      width: double.infinity,
                      height: controller.attachments.length > 1 ? 164.h : 338.w,
                    ),
                  ),

                // image
                if (e is PickedMedia && e.type == MediaAttachmentType.image)
                  SizedBox(
                    width:
                        controller.attachments.length > 1 ? width / 2 : width,
                    height: controller.attachments.length > 1 ? 164.h : 338.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image(
                        image: FileImage(
                          File(
                            e.file.path,
                          ),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                if (e is Attachment && e.isImage)
                  SizedBox(
                    width:
                        controller.attachments.length > 1 ? width / 2 : width,
                    height: controller.attachments.length > 1 ? 164.h : 338.h,
                    child: AppNetworkImage(
                      e.path,
                      fit: BoxFit.cover,
                      radius: Sizes.s20,
                    ),
                  ),
                if (e is Attachment && e.isVideo)
                  SizedBox(
                    width:
                        controller.attachments.length > 1 ? width / 2 : width,
                    height: controller.attachments.length > 1 ? 164.h : 338.h,
                    child: AppVideoPlayer(
                      e.path,
                      borderRadius: BorderRadius.circular(Sizes.s20),
                      width: double.infinity,
                      height: controller.attachments.length > 1 ? 164.h : 338.w,
                      loadingColor: AppColors.white,
                    ),
                  ),

                Positioned(
                  top: -Sizes.s8,
                  right: -Sizes.s8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.pacificBlue,
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(
                      icon: AppIcons.close,
                    ),
                  ).clickable(() {
                    controller.removeAttachment(e);
                  }),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTextField() {
    return AppTextField(
      controller: controller.postContentController,
      hintText: l10n.newsfeed__create_post_hint,
      fillColor: Colors.transparent,
      maxLines: null,
      textInputAction: TextInputAction.done,
      contentPadding: EdgeInsets.zero,
      focusNode: controller.postContentFocusNode,
      border: InputBorder.none,
      hintStyle: AppTextStyles.s16w500.copyWith(color: AppColors.grey10),
      style: AppTextStyles.s16w500.text2Color,
      // validator: (value) {
      //   if (value != null && value.length > 3000) {
      //     return 'Post content must be at least 3000 characters';
      //   }

      //   return null;
      // },
      // autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildUserPost() {
    return Row(
      children: [
        AppCircleAvatar(
          url: controller.currentUser.avatarPath ?? '',
          size: 52,
        ),
        AppSpacing.gapW12,
        Text(
          controller.currentUser.displayName.isNotEmpty
              ? controller.currentUser.displayName
              : controller.currentUser.fullName,
          style: AppTextStyles.s16w700.text2Color,
        ),
      ],
    );
  }
}
