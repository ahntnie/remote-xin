import 'package:flutter/material.dart';

import '../../../../../../core/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';

class SettingItemWidget extends StatelessWidget {
  final Object? icon;
  final String title;
  final bool isShowDivider;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingItemWidget({
    required this.icon,
    required this.title,
    this.isShowDivider = true,
    this.onTap,
    super.key,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (icon != null) ...[
              AppIcon(
                icon: icon!,
                color: AppColors.text2,
              ),
              AppSpacing.gapW8,
            ],
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.s14w400.text2Color,
              ),
            ),
            AppSpacing.gapW8,
            trailing ??
                AppIcon(
                  icon: AppIcons.arrowRight,
                  size: Sizes.s20,
                  color: AppColors.text2,
                ),
          ],
        ).clickable(() => onTap?.call()),
        if (isShowDivider)
          const Divider(height: Sizes.s24, color: AppColors.text2),
      ],
    );
  }
}
