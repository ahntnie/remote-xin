import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import 'all.dart';

class CreateStoryView extends BaseView<CreateStoryController> {
  const CreateStoryView({super.key});

  Widget _buildBackground(BuildContext context) {
    return Obx(() {
      if (controller.imagePath.value == '') {
        return Container(
          margin: EdgeInsets.fromLTRB(
            0,
            0,
            0,
            MediaQuery.of(context).size.height * 0.06,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: Color(controller.background.value),
          ),
        );
      } else if (controller.pickedMedia?.type == MediaAttachmentType.video &&
          controller.videoController.value != null &&
          controller.videoController.value!.value.isInitialized) {
        return Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: MediaQuery.of(context).size.height * 0.9,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: AspectRatio(
              aspectRatio: controller.videoController.value!.value.aspectRatio,
              child: VideoPlayer(controller.videoController.value!),
            ),
          ),
        );
      } else {
        return Container(
          margin: EdgeInsets.fromLTRB(
            0,
            0,
            0,
            MediaQuery.of(context).size.height * 0.07,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            image: DecorationImage(
              image: FileImage(File(controller.imagePath.value)),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                controller.showTextInput.value = true;
                controller.focusNode.requestFocus();
              },
              child: _buildBackground(context),
            ),
            Obx(
              () => Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.subText2.withOpacity(0.5),
                          ),
                          alignment: Alignment.centerLeft,
                          width: 40.w,
                          child: IconButton(
                            onPressed: () {},
                            icon: AppIcon(
                              icon: AppIcons.close,
                            ).clickable(() {
                              Get.back();
                            }),
                          ),
                        ),
                        const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (controller.imagePath.value == '')
                    SizedBox(
                      height: 30.h,
                      child: ListView.builder(
                        itemCount: controller.colors.length,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        itemBuilder: (context, index) => Container(
                          height: 30.h,
                          width: 30.w,
                          margin: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(controller.colors[index]),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Obx(
                            () => controller.currentIndex.value == index
                                ? const Icon(Icons.done, size: 18)
                                : AppSpacing.emptyBox,
                          ),
                        ).clickable(() {
                          controller.background.value =
                              controller.colors[index];
                          controller.currentIndex.value = index;
                        }),
                      ),
                    ),
                  AppSpacing.gapH12,
                  Positioned(
                    bottom: 16.h,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.subText2.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'Edit video',
                              style: AppTextStyles.s16w600
                                  .copyWith(color: AppColors.white),
                            ).clickable(() {
                              print('Edit story');
                            }),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'Post story',
                              style: AppTextStyles.s16w600
                                  .copyWith(color: AppColors.white),
                            ).clickable(() {
                              controller.postStory();
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16.w,
              top: MediaQuery.of(context).size.height * 0.35,
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.subText2.withOpacity(0.5),
                    radius: 20.r,
                    child: IconButton(
                      icon: const AppIcon(icon: Icons.text_fields),
                      onPressed: () {
                        print('Edit story');
                      },
                    ),
                  ),
                  AppSpacing.gapH8,
                  CircleAvatar(
                    backgroundColor: AppColors.subText2.withOpacity(0.5),
                    radius: 20.r,
                    child: IconButton(
                      icon: const AppIcon(icon: Icons.music_note),
                      onPressed: () {
                        print('Edit story');
                      },
                    ),
                  ),
                  AppSpacing.gapH8,
                  CircleAvatar(
                    backgroundColor: AppColors.subText2.withOpacity(0.5),
                    radius: 20.r,
                    child: IconButton(
                      icon: const AppIcon(icon: Icons.emoji_emotions),
                      onPressed: () {
                        print('Edit story');
                      },
                    ),
                  ),
                  AppSpacing.gapH8,
                  CircleAvatar(
                    backgroundColor: AppColors.subText2.withOpacity(0.5),
                    radius: 20.r,
                    child: IconButton(
                      icon: const AppIcon(icon: Icons.edit),
                      onPressed: () {
                        print('Edit story');
                      },
                    ),
                  ),
                  AppSpacing.gapH8,
                  CircleAvatar(
                    backgroundColor: AppColors.subText2.withOpacity(0.5),
                    radius: 20.r,
                    child: IconButton(
                      icon: const AppIcon(icon: Icons.image_outlined),
                      onPressed: () {
                        controller.getMediaFromGallery();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => !controller.showTextInput.value &&
                      controller.text.value.isNotEmpty
                  ? Positioned(
                      left: controller.textPosition.value.dx,
                      top: controller.textPosition.value.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          controller.textPosition.value += details.delta;
                        },
                        onTap: () {
                          controller.showTextInput.value = true;
                          controller.textController.value.text =
                              controller.text.value;
                          controller.focusNode.requestFocus();
                        },
                        child: Text(
                          controller.text.value,
                          style: TextStyle(
                            fontSize: controller.textSize.value,
                            color: Color(controller.textColor.value),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => controller.showTextInput.value
                  ? Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          controller.showTextInput.value = false;
                          controller.focusNode.unfocus();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            color: AppColors.text2.withOpacity(0.3),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: TextField(
                                    controller: controller.textController.value,
                                    focusNode: controller.focusNode,
                                    style: TextStyle(
                                      fontSize: controller.textSize.value,
                                      color: Color(controller.textColor.value),
                                    ),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Nhập nội dung...',
                                      hintStyle: TextStyle(color: Colors.white),
                                    ),
                                    onChanged: (value) {
                                      controller.text.value = value;
                                    },
                                    onSubmitted: (value) {
                                      controller.showTextInput.value = false;
                                      controller.focusNode.unfocus();
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16.w,
                                top: MediaQuery.of(context).size.height * 0.3,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 6.h,
                                      thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 8.r),
                                      overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: 16.r),
                                      activeTrackColor: AppColors.white,
                                      inactiveTrackColor:
                                          AppColors.subText2.withOpacity(0.3),
                                      thumbColor: AppColors.white,
                                      overlayColor:
                                          AppColors.white.withOpacity(0.2),
                                    ),
                                    child: Slider(
                                      value: controller.textSize.value,
                                      min: 16,
                                      max: 40,
                                      onChanged: (value) {
                                        controller.textSize.value = value;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: MediaQuery.of(context).viewInsets.top +
                                    25.h,
                                right: MediaQuery.of(context).viewInsets.right +
                                    25.h,
                                child: GestureDetector(
                                  onTap: () {
                                    controller.showTextInput.value = false;
                                  },
                                  child: Text(
                                    'Xong',
                                    style: AppTextStyles.s18w600,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        20.h,
                                left: 0,
                                right: 0,
                                child: SizedBox(
                                  height: 40.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller.colors.length,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                      onTap: () {
                                        controller.textColor.value =
                                            controller.colors[index];
                                      },
                                      child: Container(
                                        width: 30.w,
                                        height: 30.h,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 8.w),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              Color(controller.colors[index]),
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
