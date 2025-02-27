import 'dart:ui';

import 'package:flutter/material.dart';

import '../resource/resource.dart';

class AppBlurryContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final BoxShape boxShape;
  final Color? color;
  final Color? border;
  final double? width;

  const AppBlurryContainer({
    required this.child,
    super.key,
    this.padding = AppSpacing.edgeInsetsAll16,
    this.blur = 8.0,
    this.borderRadius = Sizes.s16,
    this.boxShape = BoxShape.rectangle,
    this.color,
    this.border,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: boxShape == BoxShape.circle
          ? BorderRadius.zero
          : BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
              shape: boxShape,
              borderRadius: boxShape == BoxShape.circle
                  ? null
                  : BorderRadius.circular(borderRadius),
              color: color ?? AppColors.opacityBackground,
              border: Border.all(
                  color: border ?? color ?? AppColors.opacityBackground,
                  width: 1.5)),
          child: child,
        ),
      ),
    );
  }
}
