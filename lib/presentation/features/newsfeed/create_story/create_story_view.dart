import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../story/views/widget/custom_textfield.dart';
import 'all.dart';

class CreateStoryView extends BaseView<CreateStoryController> {
  const CreateStoryView({super.key});

  Widget _buildTextField() {
    return AppTextField(
      hintText: l10n.newsfeed__create_post_hint,
      hintStyle: AppTextStyles.s16Base.toColor(AppColors.subText2),
      fillColor: Colors.transparent,
      maxLines: null,
      textInputAction: TextInputAction.done,
      contentPadding: EdgeInsets.zero,

      // onChanged: (value) {
      //   controller.content.value = value;
      // },
      // validator: (value) {
      //   if (value != null && value.length > 3000) {
      //     return 'Post content must be at least 3000 characters';
      //   }

      //   return null;
      // },
      // autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildBackground() => Obx(() => Container(
        decoration: controller.imagePath.value == ''
            ? BoxDecoration(color: Color(controller.background.value))
            : BoxDecoration(
                image: DecorationImage(
                  image: FileImage(
                    File(controller.imagePath.value),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
      ));

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Obx(
              () => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 46.w,
                          child: AppIcon(
                            icon: AppIcons.close,
                          ).clickable(() {
                            Get.back();
                          }),
                        ),
                        Text(
                          'Create Story',
                          style: AppTextStyles.s20w600,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Post',
                            style: AppTextStyles.s18w600,
                            textAlign: TextAlign.center,
                          ).clickable(() {
                            controller.postStory();
                          }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Obx(
                        () => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            controller.text.value,
                            style: AppTextStyles.s22w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  controller.imagePath.value == ''
                      ? SizedBox(
                          height: 30,
                          child: ListView.builder(
                            itemCount: controller.colors.length,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            itemBuilder: (context, index) => Container(
                              height: 30,
                              width: 30,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(controller.colors[index]),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Obx(
                                () => controller.currentIndex.value == index
                                    ? const Icon(
                                        Icons.done,
                                        size: 18,
                                      )
                                    : AppSpacing.emptyBox,
                              ),
                            ).clickable(
                              () {
                                controller.background.value =
                                    controller.colors[index];
                                controller.currentIndex.value = index;
                              },
                            ),
                          ),
                        )
                      : AppSpacing.emptyBox,
                  AppSpacing.gapH12,
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: CustomTextField(
                            controller: controller.textController.value,
                            name: 'Say something',
                            onChanged: (p0) {
                              controller.textController.value.text = p0;
                              controller.text.value = p0;
                            },
                            focusNode: controller.focusNode,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.getImageFromGallery();
                        },
                        icon: AppIcon(
                          size: 30,
                          icon: AppIcons.gallery,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
