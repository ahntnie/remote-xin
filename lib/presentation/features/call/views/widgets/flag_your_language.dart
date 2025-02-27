import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';

import '../../../../../core/all.dart';
import '../../../../resource/resource.dart';

class FlagYourLanguage extends StatelessWidget {
  final String talkCode;
  const FlagYourLanguage({required this.talkCode, super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex =
        languages.indexWhere((map) => map['talkCode'] == talkCode);
    return Row(children: [
      CircleFlag(size: 30, languages[currentIndex]['flagCode'] ?? ''),
      AppSpacing.gapW8,
      Text(
        languages[currentIndex]['title'] ?? '',
        style: AppTextStyles.s16Base.text2Color,
      ),
    ]);
  }
}
