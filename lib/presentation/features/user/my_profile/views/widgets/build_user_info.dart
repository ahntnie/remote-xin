import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/extensions/all.dart';
import '../../../../../../models/user.dart';
import '../../../../../base/base_view.dart';
import '../../../../../common_widgets/app_icon.dart';
import '../../../../../resource/resource.dart';
import '../../controllers/my_profile_controller.dart';

/// Widget for rendering user information
///
/// [currentUser] is the user object with type [User], which contains user information
class BuildUserInfo extends BaseView<MyProfileController> {
  @override
  final User currentUser;

  const BuildUserInfo({required this.currentUser, super.key});

  final double iconSize = 24;

  @override
  Widget buildPage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 12, right: 12),
      height: 0.5.sh,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSpacing.gapW8,
                AppIcon(
                  icon: Assets.icons.mailFill,
                  color: AppColors.grey10,
                  size: iconSize,
                ),
                AppSpacing.gapW12,
                Flexible(
                  child: Text(
                    controller.userEmailText.value,
                    // 'hovuminhquang@gmail.com',
                    style: AppTextStyles.s16w500.toColor(AppColors.text2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            AppSpacing.gapH16,
            Row(
              children: [
                AppSpacing.gapW8,
                AppIcon(
                  icon: Assets.icons.phoneFill,
                  color: AppColors.grey10,
                  size: 22,
                ),
                AppSpacing.gapW12,
                Text(
                  controller.userPhoneText.value,
                  style: AppTextStyles.s16w500.toColor(AppColors.text2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            AppSpacing.gapH16,
            Row(
              children: [
                AppSpacing.gapW8,
                AppIcon(
                  icon: Assets.icons.nftFill,
                  color: AppColors.grey10,
                  size: iconSize,
                ),
                AppSpacing.gapW12,
                Text(
                  controller.userNftText.value,
                  style: AppTextStyles.s16w500.toColor(AppColors.text2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            AppSpacing.gapH16,
            Row(
              children: [
                AppSpacing.gapW8,
                Row(
                  children: [
                    AppIcon(
                      // icon: currentUser.gender == context.l10n.text_gender_male
                      //     ? Assets.icons.male
                      //     : currentUser.gender == context.l10n.text_gender_female
                      //         ? Assets.icons.female
                      //         : Assets.icons.venusMars,
                      icon: Assets.icons.gender,
                      color: AppColors.grey10,
                    ),
                    AppSpacing.gapW12,
                    Text(
                      controller.userGender.value,
                      style: AppTextStyles.s16w500.toColor(AppColors.text2),
                    )
                  ],
                ),
              ],
            ),
            AppSpacing.gapH16,
            Row(
              children: [
                AppSpacing.gapW8,
                AppIcon(
                  icon: Assets.icons.age,
                  color: AppColors.grey10,
                  size: iconSize,
                ),
                AppSpacing.gapW12,
                Text(
                  controller.userAgeValueText.value,
                  style: AppTextStyles.s16w500.toColor(AppColors.text2),
                )
              ],
            ),
            AppSpacing.gapH16,
            Row(
              children: [
                AppSpacing.gapW8,
                AppIcon(
                  icon: Assets.icons.locationPin,
                  color: AppColors.grey10,
                  size: iconSize,
                ),
                AppSpacing.gapW12,
                Text(
                  controller.userLocationText.value,
                  style: AppTextStyles.s16w500.toColor(AppColors.text2),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

int calculateAge(String birth) {
  // Chuyển đổi chuỗi ngày sinh thành DateTime
  final DateTime birthDate = DateFormat('MM/dd/yyyy').parse(birth);
  final DateTime currentDate = DateTime.now();

  int age = currentDate.year - birthDate.year;

  // Kiểm tra nếu ngày sinh chưa đến trong năm hiện tại thì trừ 1 tuổi
  if (currentDate.month < birthDate.month ||
      (currentDate.month == birthDate.month &&
          currentDate.day < birthDate.day)) {
    age--;
  }

  return age;
}
