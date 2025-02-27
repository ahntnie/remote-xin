import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import 'all.dart';

class PostInputResourceView extends GetView<PostInputResourceController> {
  const PostInputResourceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: Sizes.s16,
        bottom: Sizes.s20,
        left: Sizes.s20,
        right: Sizes.s20,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Sizes.s20),
          topRight: Radius.circular(Sizes.s20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.text2.withOpacity(0.27),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 4,
            margin: const EdgeInsets.only(bottom: Sizes.s16),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.grey10,
            ),
          ),
          AppSpacing.gapH8,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItem(
                title:
                    '${context.l10n.newsfeed__image}/${context.l10n.newsfeed__video}',
                icon: AppIcons.image,
                onTap: () {
                  controller.pickMedia();
                },
                color: AppColors.green1,
              ),
              _buildItem(
                title: context.l10n.newsfeed__camera,
                icon: AppIcons.camera,
                onTap: () {
                  controller.takePhotoFromCamera();
                },
                color: AppColors.blue4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String title,
    required Object icon,
    required Function onTap,
    Color? color,
  }) {
    return Row(
      children: [
        AppIcon(
          icon: icon,
          color: color,
        ),
        AppSpacing.gapW12,
        Text(
          title,
          style: AppTextStyles.s16w500.copyWith(color: AppColors.text2),
        ),
      ],
    ).paddingSymmetric(vertical: Sizes.s12).clickable(() {
      onTap();
    });
  }
}
