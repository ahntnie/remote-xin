import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resource/resource.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.2.sw,
      height: 5,
      decoration: BoxDecoration(
          color: AppColors.grey10, borderRadius: BorderRadius.circular(100)),
    );
  }
}
