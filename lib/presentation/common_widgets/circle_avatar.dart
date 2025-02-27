import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resource/resource.dart';
import 'all.dart';

class AppCircleAvatar extends StatelessWidget {
  final String url;
  final double? size;
  final Color? backgroundColor;

  const AppCircleAvatar({
    required this.url,
    this.size,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final finalSize = size ?? 50.r;

    return AppNetworkImage(
      url,
      radius: finalSize / 2,
      width: finalSize,
      height: finalSize,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        backgroundImage: ResizeImage(
          imageProvider,
          width: finalSize.toInt().cacheSize(context),
        ),
      ),
      errorWidget: _buildFallbackWidget(finalSize),
    );
  }

  Widget _buildFallbackWidget(double finalSize) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: finalSize / 2,
        backgroundColor: AppColors.grey6,
        child: AppIcon(
          icon: Assets.icons.person,
          color: AppColors.text2,
          size: finalSize / 2,
        ),
      ),
    );
  }
}
