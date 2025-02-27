import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../resource/styles/styles.dart';

class AppDefaultLoading extends StatelessWidget {
  const AppDefaultLoading({
    super.key,
    this.color,
    this.size = Sizes.s32,
    this.strokeWidth = Sizes.s2,
    this.label,
  });

  final Color? color;
  final double size;
  final double strokeWidth;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final loading = SizedBox.square(
      dimension: size,
      child: Platform.isAndroid
          ? _buildAndroidLoading(context)
          : _buildIOSLoading(context),
    );

    return Center(
      child: label == null
          ? loading
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                loading,
                AppSpacing.gapH8,
                Text(
                  label!,
                  style: AppTextStyles.s12w400,
                ),
              ],
            ),
    );
  }

  Widget _buildAndroidLoading(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.blue10),
      strokeWidth: strokeWidth,
    );
  }

  Widget _buildIOSLoading(BuildContext context) {
    return CupertinoActivityIndicator(
      color: color ?? AppColors.primary,
      radius: size / 2,
    );
  }
}
