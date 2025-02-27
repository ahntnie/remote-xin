import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../core/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../all.dart';
import 'widgets/image_gallery_create_post.dart';

class CreatePostView extends BaseView<CreatePostController> {
  const CreatePostView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    // Set the status bar icon color to black (dark mode)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Set the icon color to black
        statusBarBrightness:
            Brightness.light, // For iOS status bar background color
      ),
    );
    return CommonScaffold(
      hideKeyboardWhenTouchOutside: true,
      appBar: CommonAppBar(
        leadingIcon: LeadingIcon.close,
        leadingIconColor: AppColors.text2,
        centerTitle: false,
        onLeadingPressed: () {
          controller.postInputResourceController.pickedListMedia.clear();
          Get.back();
        },
        text: l10n.newsfeed__create_post_title,
        titleTextStyle: AppTextStyles.s18w700.text2Color,
        titleType: AppBarTitle.text,
        actions: [
          Obx(
            () => Text(
              l10n.next,
              style: AppTextStyles.s16w500.copyWith(
                color: (controller.postInputResourceController.pickedListMedia
                            .toList()
                            .isNotEmpty ||
                        controller.isHaveText.value)
                    ? AppColors.blue10
                    : AppColors.grey10,
                fontWeight: (controller
                            .postInputResourceController.pickedListMedia
                            .toList()
                            .isNotEmpty ||
                        controller.isHaveText.value)
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ).clickable(() {
              controller.uploadPost();
            }),
          ),
        ],
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
    return ImageGalleryCreatePost(controller: controller);
  }

  Widget _buildImageGalleryOld() {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth - Sizes.s60;

      return Wrap(
        alignment: WrapAlignment.center,
        runSpacing: Sizes.s20,
        spacing: Sizes.s20,
        children:
            controller.postInputResourceController.pickedListMedia.map((e) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (e.type == MediaAttachmentType.video)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AppVideoPlayer(
                    e.file.path,
                    isFile: true,
                    isThumbnailMode: true,
                    isClickToShowFullScreen: true,
                    borderRadius: BorderRadius.circular(Sizes.s20),
                    width: controller.postInputResourceController
                                .pickedListMedia.length >
                            1
                        ? width / 2
                        : width,
                    height: controller.postInputResourceController
                                .pickedListMedia.length >
                            1
                        ? 164.h
                        : 338.w,
                  ),
                ),

              // image
              if (e.type == MediaAttachmentType.image)
                SizedBox(
                  width: controller.postInputResourceController.pickedListMedia
                              .length >
                          1
                      ? width / 2
                      : width,
                  height: controller.postInputResourceController.pickedListMedia
                              .length >
                          1
                      ? 164.h
                      : 338.h,
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
              Positioned(
                top: -Sizes.s8,
                right: -Sizes.s8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.zambezi.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    icon: AppIcons.close,
                  ),
                ).clickable(() {
                  controller.postInputResourceController.removeMedia(e);
                }),
              ),
            ],
          );
        }).toList(),
      );
    });
  }

  Widget _buildUserPost() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
        ),
      ],
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
}
