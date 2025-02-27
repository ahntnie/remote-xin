import 'package:flutter/material.dart';

import '../resource/resource.dart';
import 'all.dart';

enum AppButtonType { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.padding,
    this.isDisabled = false,
    this.textStyleLabel,
    this.color,
  })  : type = AppButtonType.primary,
        assert(
          label != null || icon != null,
          'Label or icon must be provided.',
        );

  const AppButton.secondary({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.padding,
    this.isDisabled = false,
    this.textStyleLabel,
    this.color,
  })  : type = AppButtonType.secondary,
        assert(
          label != null || icon != null,
          'Label or icon must be provided.',
        );

  final String? label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final EdgeInsets? padding;
  final AppButtonType type;
  final bool isDisabled;
  final TextStyle? textStyleLabel;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    const textColor = AppColors.text1;

    final textStyles = AppTextStyles.s18w500.copyWith(
      color:
          (type == AppButtonType.secondary) ? AppColors.pacificBlue : textColor,
      height: 1.2,
    );

    final child = isLoading
        ? SizedBox(height: 20, width: 20, child: _buildLoading(textColor))
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                SizedBox.square(dimension: Sizes.s20, child: icon),
              if (icon != null && label != null) AppSpacing.gapW4,
              if (label != null)
                Text(
                  label!,
                  textAlign: TextAlign.center,
                  style: textStyleLabel ?? textStyles,
                ),
            ],
          );

    final finalBorderRadius = BorderRadius.circular(borderRadius ?? Sizes.s128);
    final finalPadding = padding ?? AppSpacing.edgeInsetsAll16;

    var button = Container(
      decoration: BoxDecoration(
        color: color ?? (isDisabled ? AppColors.blue8 : AppColors.blue10),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.25),
        //     blurRadius: 2.3,
        //   ),
        // ],
        borderRadius: finalBorderRadius,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          textStyle: textStyles,
          shape: RoundedRectangleBorder(borderRadius: finalBorderRadius),
          padding: finalPadding,
        ),
        onPressed: isDisabled ? null : onPressed,
        child: child,
      ),
    );

    if (type == AppButtonType.secondary) {
      button = Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.pacificBlue),
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
          borderRadius: finalBorderRadius,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            textStyle: textStyles,
            shape: RoundedRectangleBorder(borderRadius: finalBorderRadius),
            padding: finalPadding,
          ),
          onPressed: isDisabled ? null : onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }

  Widget _buildLoading(Color color) {
    return AppDefaultLoading(
      size: Sizes.s20,
      color: color,
    );
  }
}
