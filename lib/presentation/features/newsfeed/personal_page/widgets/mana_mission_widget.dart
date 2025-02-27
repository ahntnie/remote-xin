import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../../routing/routing.dart';
import '../all.dart';
import 'mana_mission_day_item_widget.dart';
import 'shimmer_loading_mission.dart';

class ManaMissionWidget extends GetView<PersonalPageController> {
  const ManaMissionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isLoadingInit.value
        ? Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey11,
                    borderRadius: BorderRadius.circular(Sizes.s12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: Sizes.s20,
                    vertical: Sizes.s24,
                  ),
                  padding: const EdgeInsets.only(
                    left: Sizes.s20,
                    top: Sizes.s20,
                    bottom: Sizes.s12,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: Sizes.s24,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  context.l10n.profile__misson_daily_label,
                                  style: AppTextStyles.s18w700.copyWith(
                                    color: AppColors.text2,
                                  ),
                                ),
                                const Spacer(),
                                // Row(
                                //   children: [
                                //     Obx(
                                //       () => Text(
                                //         '${controller.mana?.mana ?? 0}/${controller.mana?.maxMana ?? 50}',
                                //         style: AppTextStyles.s16w700.copyWith(
                                //           color: AppColors.pacificBlue,
                                //         ),
                                //       ),
                                //     ),
                                //     AppSpacing.gapW4,
                                //     const CircleAvatar(
                                //       backgroundColor: AppColors.pacificBlue,
                                //       radius: Sizes.s14,
                                //       child: Icon(
                                //         Icons.add,
                                //         color: AppColors.white,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                // AppIcon(
                                //   icon: Assets.icons.arrowUp,
                                //   color: Colors.black,
                                //   padding: AppSpacing.edgeInsetsAll8,
                                //   size: 20,
                                // ),
                              ],
                            ),
                            // AppSpacing.gapH4,
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     ManaMissionTypeWidget(
                            //       missionManaType: controller.rxMissionManaType,
                            //     ),
                            //     InkWell(
                            //       onTap: controller.onRefreshManaMission,
                            //       child: const CircleAvatar(
                            //         backgroundColor: AppColors.pacificBlue,
                            //         radius: Sizes.s14,
                            //         child: Icon(
                            //           Icons.cached_outlined,
                            //           color: AppColors.white,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            AppSpacing.gapH4,
                            Text(
                              context.l10n.profile__mission_daily_text,
                              style: AppTextStyles.s16w500
                                  .toColor(AppColors.grey10),
                            ),
                            AppSpacing.gapH12,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 189.h,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) =>
                                const ShimmerLoadingMission(),
                            itemCount: 2),
                      ),
                      AppSpacing.gapH12,
                    ],
                  ),
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey11,
                    borderRadius: BorderRadius.circular(Sizes.s12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: Sizes.s20,
                    vertical: Sizes.s24,
                  ),
                  padding: const EdgeInsets.only(
                    left: Sizes.s20,
                    top: Sizes.s20,
                    bottom: Sizes.s12,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: Sizes.s24,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  context.l10n.profile__misson_daily_label,
                                  style: AppTextStyles.s18w700.copyWith(
                                    color: AppColors.text2,
                                  ),
                                ),
                                const Spacer(),
                                // Row(
                                //   children: [
                                //     Obx(
                                //       () => Text(
                                //         '${controller.mana?.mana ?? 0}/${controller.mana?.maxMana ?? 50}',
                                //         style: AppTextStyles.s16w700.copyWith(
                                //           color: AppColors.pacificBlue,
                                //         ),
                                //       ),
                                //     ),
                                //     AppSpacing.gapW4,
                                //     const CircleAvatar(
                                //       backgroundColor: AppColors.pacificBlue,
                                //       radius: Sizes.s14,
                                //       child: Icon(
                                //         Icons.add,
                                //         color: AppColors.white,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                AppIcon(
                                  icon: Assets.icons.arrowUp,
                                  color: Colors.black,
                                  padding: AppSpacing.edgeInsetsAll8,
                                  size: 20,
                                ),
                              ],
                            ),
                            // AppSpacing.gapH4,
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     ManaMissionTypeWidget(
                            //       missionManaType: controller.rxMissionManaType,
                            //     ),
                            //     InkWell(
                            //       onTap: controller.onRefreshManaMission,
                            //       child: const CircleAvatar(
                            //         backgroundColor: AppColors.pacificBlue,
                            //         radius: Sizes.s14,
                            //         child: Icon(
                            //           Icons.cached_outlined,
                            //           color: AppColors.white,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            AppSpacing.gapH4,
                            Text(
                              context.l10n.profile__mission_daily_text,
                              style: AppTextStyles.s16w500
                                  .toColor(AppColors.grey10),
                            ),
                            AppSpacing.gapH12,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 189.h,
                        child: Obx(
                          () => ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => controller
                                    .isLoadingInit.value
                                ? const ShimmerLoadingMission()
                                : ManaMissionDayItemWidget(
                                    manaMission: controller.manaMissions[index],
                                  ),
                            itemCount: controller.isLoadingInit.value
                                ? 2
                                : controller.manaMissions.length,
                          ),
                        ),
                      ),
                      AppSpacing.gapH12,
                    ],
                  ),
                ).clickable(
                  () => Get.toNamed(Routes.mission),
                ),
              ),
            ],
          ));
  }
}
