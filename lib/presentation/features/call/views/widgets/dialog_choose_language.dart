import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../../core/all.dart';
import '../../../../../models/user.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../user/settings/widgets/choose_language_widget.dart';

Future<T?> showAlertDialogChooseLanguage<T>(
    String talkLanguage,
    BuildContext context,
    int currentId,
    String currentLastname,
    String currentFirstname,
    String currentPhone,
    String currentAvatar,
    String currentNicknme,
    String currentEmail,
    VoidCallback? onTapStart,
    User user) {
  const backgroundColor = AppColors.white;

  const buttonColor = AppColors.button5;
  String talkCode = talkLanguage;
  int currentIndex;

  return Get.dialog<T>(
    StatefulBuilder(builder: (context, setState) {
      currentIndex = languages.indexWhere((map) => map['talkCode'] == talkCode);
      return Dialog(
          child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          // border: Border.all(width: 6, color: borderDialogColor),
          borderRadius: BorderRadius.circular(
              Sizes.s20), // Adjust border radius if needed
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: Sizes.s16, vertical: Sizes.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.successIcon.image(height: 120.h, width: 120.w),
            AppSpacing.gapH8,
            Padding(
              padding: const EdgeInsets.only(right: Sizes.s16, left: Sizes.s16),
              child: Text(
                context.l10n.language__notification,
                textAlign: TextAlign.center,
                style: AppTextStyles.s18w600.copyWith(color: AppColors.text2),
              ),
            ),
            AppSpacing.gapH8,
            Padding(
              padding: const EdgeInsets.only(right: Sizes.s16, left: Sizes.s16),
              child: Text(
                context.l10n.language__choose_your_language,
                textAlign: TextAlign.center,
                style: AppTextStyles.s16Base.copyWith(color: AppColors.text2),
              ),
            ),
            AppSpacing.gapH8,
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleFlag(size: 30, languages[currentIndex]['flagCode'] ?? ''),
                AppSpacing.gapW8,
                Text(
                  languages[currentIndex]['title'] ?? '',
                  style: AppTextStyles.s16Base.copyWith(color: AppColors.text2),
                ),
                AppSpacing.gapW8,
                const AppIcon(
                  icon: Icons.keyboard_arrow_down,
                  color: Colors.black,
                )
              ],
            ).clickable(() {
              showCupertinoModalBottomSheet(
                  topRadius: const Radius.circular(30),
                  context: context,
                  builder: (context) => ChooseLanguageWidget(
                        languageCode: talkCode,
                        idUser: 0,
                        type: 'dialog',
                        currentId: currentId,
                        currentFirstname: currentFirstname,
                        currentLastname: currentLastname,
                        currentAvatar: currentAvatar,
                        currentEmail: currentEmail,
                        currentNicknme: currentNicknme,
                        currentPhone: currentPhone,
                        user: user,
                      )).then((value) {
                if (value != null) {
                  setState(() {
                    talkCode = value;
                  });
                }
              });
            }),
            AppSpacing.gapH8,
            AppButton.secondary(
              onPressed: () => Get.back(),
              width: double.infinity,
              label: context.l10n.language__close,
            ),
            AppSpacing.gapH4,
            Container(
              width: double.infinity,
              padding: AppSpacing.edgeInsetsAll16,
              decoration: BoxDecoration(
                color: AppColors.blue10,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 2.3,
                  ),
                  // const BoxShadow(
                  //   color: AppColors
                  //       .buttonSecondBorder, // #8FC9E9 với opacity khoảng 31%
                  //   offset: Offset(0, 2), // X: 0, Y: 2
                  //   blurRadius: 4, // Blur: 4
                  // ),
                ],
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                context.l10n.language__start,
                textAlign: TextAlign.center,
                style: AppTextStyles.s18w500.copyWith(
                  color: AppColors.text1,
                  height: 1.2,
                ),
              ),
            ).clickable(() {
              if (onTapStart != null) {
                onTapStart();
              }
            })
            // AppButton.secondary(
            //   color: AppColors.blue10,
            //   onPressed: onTapStart,
            //   width: double.infinity,
            //   label: context.l10n.language__start,
            // ),
          ],
        ),
      ));
    }),
    barrierDismissible: false,
  );
}
