import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/all.dart';
import '../../base/all.dart';
import '../../common_controller.dart/language_controller.dart';
import '../../common_widgets/all.dart';
import '../../resource/resource.dart';
import '../all.dart';
import 'mission_controller.dart';

class MissionView extends BaseView<MissionController> {
  const MissionView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    final personController = Get.find<PersonalPageController>();
    final languageController = Get.find<LanguageController>();

    return CommonScaffold(
      appBar: CommonAppBar(
        titleWidget: Text(
          l10n.mana_mission__challenges,
          style: AppTextStyles.s18w700.text2Color,
        ).clickable(() => Get.back()),
        centerTitle: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: const LinearGradient(
                  colors: [Color(0xff0E81FC), Color(0xff369C09)],
                )),
            child: Text(l10n.text_node_package),
          ).clickable(
            () => IntentUtils.openBrowserURL(url: AppConstants.webSystemURL),
          ),
        ],
      ),
      body: Padding(
        padding: AppSpacing.edgeInsetsH20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.gapH20,
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.grey11,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Assets.images.yourMana.image(scale: 2),
                        AppSpacing.gapW16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: const Color(0xffdee7fd),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppIcon(
                                      icon: Assets.icons.mingcute,
                                      color: AppColors.blue10,
                                      size: 20,
                                    ),
                                    AppSpacing.gapW4,
                                    Text(
                                      l10n.daily_mission__your_mana,
                                      style: AppTextStyles.s12w500
                                          .toColor(AppColors.blue10),
                                    ),
                                    AppSpacing.gapW4,
                                    AppIcon(
                                      icon: Assets.icons.mingcute,
                                      color: AppColors.blue10,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              AppSpacing.gapH12,
                              Text(
                                '${personController.mana!.mana ?? 0} Mana',
                                style: AppTextStyles.s18w700
                                    .toColor(AppColors.text2),
                              ),
                              AppSpacing.gapH12,
                              Text(
                                l10n.daily_mission__text,
                                style: AppTextStyles.s16w400
                                    .toColor(AppColors.subText2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapH12,
                  LinearPercentIndicator(
                    lineHeight: 18,
                    percent: personController.mana!.mana != null
                        ? personController.mana!.mana!.toDouble() / 50 > 1
                            ? 1
                            : personController.mana!.mana!.toDouble() / 50
                        : 0,
                    barRadius: const Radius.circular(100),
                    backgroundColor: const Color(0xffA0BEDF),
                    progressColor: AppColors.blue10,
                    center: Text(
                      '${personController.mana!.mana ?? 0}/50',
                      style: AppTextStyles.s14w500,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH20,
            Text(
              l10n.profile__misson_daily_label,
              style: AppTextStyles.s18w700.text2Color,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: personController.manaMissions.length,
                itemBuilder: (context, index) {
                  String getLanguageValue(String key) {
                    return personController
                        .manaMissions[index].userMission?.languages![key];
                  }

                  final accomplete = personController
                          .manaMissions[index].progress?.accomplished ??
                      0;

                  final total =
                      personController.manaMissions[index].progress?.total == 0
                          ? 1
                          : personController
                                  .manaMissions[index].progress?.total ??
                              1;

                  return Column(
                    children: [
                      AppSpacing.gapH12,
                      Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: personController
                                    .manaMissions[index].userMission?.image ??
                                '',
                            width: 40.w,
                            height: 40.w,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) => Assets.icons.image.svg(
                              width: 40.w,
                              height: 40.w,
                              color: AppColors.negative,
                            ),
                          ),
                          AppSpacing.gapW16,
                          Expanded(
                            child: Text(
                              getLanguageValue(languageController.languages[
                                          languageController.currentIndex.value]
                                      ['flagCode'] ??
                                  'en'),
                              style: AppTextStyles.s16w600.text2Color,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: SizedBox(
                              height: 60,
                              width: 60,
                              child: CircularPercentIndicator(
                                radius: 30,
                                percent: accomplete / total,
                                fillColor: accomplete / total != 0
                                    ? const Color(0xffe4fce9)
                                    : const Color(0xffebf1f3),
                                backgroundColor: accomplete / total != 0
                                    ? const Color(0xffd3f0df)
                                    : const Color(0xffdae5e9),
                                progressColor: const Color(0xff1cc62b),
                                center: Text(
                                  '${personController.manaMissions[index].progress?.accomplished} / ${personController.manaMissions[index].progress?.total}',
                                  style: AppTextStyles.s12w700
                                      .copyWith(fontSize: 13)
                                      .toColor(const Color(0xffa4a4a4)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((index + 1) != personController.manaMissions.length)
                        const Divider(
                          height: 1,
                          color: AppColors.subText2,
                        ).paddingSymmetric(vertical: 16)
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
