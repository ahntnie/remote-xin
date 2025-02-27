import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../common_controller.dart/all.dart';
import '../../../../common_widgets/app_icon.dart';
import '../../../../common_widgets/circle_avatar.dart';
import '../../../../resource/resource.dart';
import '../../../../routing/routers/app_pages.dart';

class EditProfileWidget extends StatelessWidget {
  final String avatarPath;
  final String fullName;
  const EditProfileWidget(
      {required this.avatarPath, required this.fullName, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.edgeInsetsAll12,
      margin: const EdgeInsets.only(
        top: Sizes.s20,
        left: Sizes.s20,
        right: Sizes.s20,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey11,
        borderRadius: BorderRadius.circular(Sizes.s12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppCircleAvatar(
            url: avatarPath,
            size: 40,
          ),
          AppSpacing.gapW12,
          Text(
            fullName,
            style: AppTextStyles.s18w700.text2Color,
          ),
          const Spacer(),
          AppIcon(
            icon: Assets.icons.arrowUp,
            color: Colors.black,
            padding: AppSpacing.edgeInsetsAll8,
            size: 20,
          ),
        ],
      ).clickable(() {
        // Get.find<ContactController>().getUserContacts();
        Get.toNamed(Routes.myProfile, arguments: {
          'isMine': true,
          'user': Get.find<AppController>().currentUser,
          'isAddContact': false,
        });
      }),
    );
  }
}
