import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/extensions/all.dart';
import '../resource/gen/assets.gen.dart';
import '../resource/styles/styles.dart';
import 'all.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  CommonAppBar({
    Key? key,
    this.text,
    this.onLeadingPressed,
    this.onTitlePressed,
    this.leadingIcon = LeadingIcon.back,
    this.titleType = AppBarTitle.logo,
    this.centerTitle = true,
    this.elevation = 0,
    this.actions,
    this.height,
    this.automaticallyImplyLeading = true,
    this.flexibleSpace,
    this.bottom,
    this.shadowColor,
    this.shape,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.excludeHeaderSemantics = false,
    this.titleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.leadingWidth = 44.0,
    this.titleTextStyle,
    this.systemOverlayStyle,
    this.leadingIconColor,
    this.leadingIconWidget,
    this.titleWidget,
  })  : preferredSize = Size.fromHeight(height ?? Sizes.s56),
        super(key: key);

  final String? text;
  final VoidCallback? onLeadingPressed;
  final VoidCallback? onTitlePressed;
  final LeadingIcon leadingIcon;
  final AppBarTitle titleType;
  final bool centerTitle;
  final double elevation;
  final List<Widget>? actions;
  final double? height;
  final bool automaticallyImplyLeading;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final Color? shadowColor;
  final ShapeBorder? shape;
  final Color backgroundColor;
  final Color? foregroundColor;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  final bool primary;
  final bool excludeHeaderSemantics;
  final double? titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;
  final double? leadingWidth;
  final TextStyle? titleTextStyle;
  final Color? leadingIconColor;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final Widget? leadingIconWidget;
  final Widget? titleWidget;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: automaticallyImplyLeading,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      shadowColor: shadowColor,
      shape: shape,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      primary: primary,
      excludeHeaderSemantics: excludeHeaderSemantics,
      titleSpacing: titleSpacing,
      toolbarOpacity: toolbarOpacity,
      bottomOpacity: bottomOpacity,
      systemOverlayStyle: systemOverlayStyle ??
          const SystemUiOverlayStyle(
            statusBarIconBrightness:
                Brightness.dark, // Set the icon color to black
            statusBarBrightness:
                Brightness.light, // For iOS status bar background color
          ),
      leadingWidth: leadingWidth,
      leading:
          leadingIcon == LeadingIcon.none ? null : _buildLeadingIcon(context),
      centerTitle: centerTitle,
      title: _buildTitle(),
      actions: _buildActions(),
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
    );
  }

  Widget? _buildLeadingIcon(BuildContext context) {
    if (!automaticallyImplyLeading) {
      return null;
    }

    Object? icon;
    switch (leadingIcon) {
      case LeadingIcon.back:
        icon = AppIcons.arrowLeft;
        break;
      case LeadingIcon.close:
        icon = AppIcons.close;
        break;
      case LeadingIcon.custom:
        return leadingIconWidget;
      default:
        break;
    }

    if (icon == null) {
      return AppSpacing.emptyBox;
    }

    if (leadingIcon == LeadingIcon.button) {
      return leadingIconWidget;
    }

    return AppIcon(
      padding: const EdgeInsets.only(left: Sizes.s20),
      icon: icon,
      color: leadingIconColor ?? AppColors.text2,
    ).clickable(onLeadingPressed ?? Get.back);
  }

  Widget? _buildTitle() {
    if (titleWidget != null) {
      return titleWidget;
    }

    Widget? title;

    switch (titleType) {
      case AppBarTitle.text:
        title = Text(text ?? '', style: _getAppBarTextStyle());
      case AppBarTitle.logo:
        title = _buildLogo();
      default:
        return null;
    }

    if (onTitlePressed != null) {
      title = title.clickable(onTitlePressed!);
    }

    return title;
  }

  Widget _buildLogo() {
    return Assets.images.logo1.image(
      height: Sizes.s52,
    );
  }

  TextStyle _getAppBarTextStyle() {
    if (titleTextStyle != null) {
      return titleTextStyle!;
    }

    return AppTextStyles.s20w600.text4Color;
  }

  List<Widget>? _buildActions() {
    if (actions == null || actions!.isEmpty) {
      return null;
    }

    return [
      ...actions!,
      AppSpacing.gapW20,
    ];
  }
}

enum LeadingIcon {
  back,
  close,
  custom,
  none,
  button,
}

enum AppBarTitle {
  text,
  logo,
  none,
}
