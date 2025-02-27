import 'package:flutter/material.dart';

import '../resource/resource.dart';

class AppDivider extends StatelessWidget {
  final Color? color;
  final double? height;
  const AppDivider({super.key, this.color, this.height});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color ?? AppColors.grey6,
      thickness: 0.5,
      height: height ?? 1,
    );
  }
}
