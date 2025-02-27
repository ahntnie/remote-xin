import 'package:flutter/material.dart';

import '../resource/resource.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Text(
      'XINTEL',
      style: AppTextStyles.s28w700.copyWith(
          color: AppColors.blue10, fontSize: size, fontWeight: FontWeight.w800),
    );
  }
}
