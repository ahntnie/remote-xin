import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/mana_mission/mana_mission.dart';
import '../../../../common_controller.dart/language_controller.dart';
import '../../../../resource/resource.dart';

class ManaMissionDayItemWidget extends StatelessWidget {
  final ManaMission manaMission;

  const ManaMissionDayItemWidget({
    required this.manaMission,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    String getLanguageValue(String key) {
      return manaMission.userMission?.languages![key];
    }

    return Container(
      width: 132.w,
      height: 189.h,
      margin: const EdgeInsets.only(right: Sizes.s8),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            child: Container(
              height: 176.h,
              width: 132.w,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.pacificBlue),
                  borderRadius: BorderRadius.circular(Sizes.s8),
                  color: AppColors.pacificBlue.withOpacity(0.1)),
              padding: EdgeInsets.symmetric(
                vertical: Sizes.s8.h,
                horizontal: Sizes.s12.w,
              ),
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: manaMission.userMission?.image ?? '',
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Assets.icons.image.svg(
                      width: 50.w,
                      height: 50.w,
                      color: AppColors.negative,
                    ),
                  ),
                  AppSpacing.gapH8,
                  Expanded(
                    child: Obx(() => AutoSizeText(
                          getLanguageValue(languageController.languages[
                                      languageController.currentIndex.value]
                                  ['flagCode'] ??
                              'en'),
                          style: AppTextStyles.s12w600
                              .copyWith(color: AppColors.text2),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                  AppSpacing.gapH8,
                  Text(
                    '${manaMission.progress?.accomplished ?? 0}/${manaMission.progress?.total ?? 0}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zambezi,
                    ),
                  ),
                  AppSpacing.gapH8,
                ],
              ),
            ),
          ),
          Positioned(
            top: 176.h - 13.h,
            child: Container(
              height: 26.h,
              decoration: BoxDecoration(
                color: manaMission.isComplete()
                    ? AppColors.positive
                    : AppColors.pacificBlue,
                borderRadius: BorderRadius.circular(Sizes.s40),
              ),
              padding: EdgeInsets.symmetric(horizontal: Sizes.s20.w),
              child: Center(
                child: Text(
                  manaMission.isComplete()
                      ? context.l10n.mana_mission__complete
                      : '+${manaMission.userMission?.reward ?? 0} Mana',
                  style: AppTextStyles.s14w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
