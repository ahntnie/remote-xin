import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../models/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import 'flag_talk_language.dart';

class InfoUserWidget extends StatelessWidget {
  final User? user;
  final bool isTranslate;

  const InfoUserWidget(
      {required this.user, required this.isTranslate, super.key});

  @override
  Widget build(BuildContext context) {
    final flagCode = languages.firstWhere(
        (map) => map['talkCode'] == user?.talkLanguage,
        orElse: () => {'flagCode': ''});

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            AppCircleAvatar(size: 110.w, url: user?.avatarPath ?? ''),
            if (isTranslate)
              Positioned(
                bottom: 0,
                right: 0,
                child: FlagTalkLanguage(flagCode: flagCode['flagCode'] ?? ''),
              ),
          ],
        ),
        AppSpacing.gapH28,
        Text(
          user?.fullName ?? '',
          style: AppTextStyles.s20w600.copyWith(color: AppColors.text2),
        ),
      ],
    );
  }
}
