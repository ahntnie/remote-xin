import 'package:flutter/material.dart';

import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';

class IconButtonAction extends StatelessWidget {
  final SvgGenImage icon;
  final VoidCallback onPressed;
  final String title;
  final String content;
  final double size;
  final Color colorIcon;
  final Color colorText;
  final Color colorContent;
  final bool isLoading;

  const IconButtonAction({
    super.key,
    this.size = Sizes.s28,
    this.colorIcon = Colors.black,
    this.colorText = Colors.black,
    this.colorContent = AppColors.zambezi,
    this.content = '',
    this.isLoading = false,
    required this.icon,
    required this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // icon
              isLoading
                  ? Container(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(),
                    )
                  : AppIcon(
                      color: colorIcon,
                      icon: icon,
                      size: size,
                    ),
              AppSpacing.gapW8,
              // title
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.s16w700.copyWith(color: colorText),
                    ),
                    Text(
                      content,
                      style: AppTextStyles.s12Base.copyWith(
                          color: colorContent, overflow: TextOverflow.clip),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
