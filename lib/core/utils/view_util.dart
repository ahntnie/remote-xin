import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../presentation/common_widgets/all.dart';
import '../../presentation/resource/resource.dart';
import '../all.dart';

class ViewUtil {
  const ViewUtil._();

  static void showAppSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
    Color? backgroundColor,
  }) {
    final messengerState = ScaffoldMessenger.maybeOf(context);
    if (messengerState == null) {
      return;
    }

    messengerState.hideCurrentSnackBar();
    messengerState.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? DurationConstants.defaultSnackBarDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        margin: AppSpacing.edgeInsetsH20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.s8),
        ),
      ),
    );
  }

  static void showAppSnackBarCustom(
    BuildContext context,
    EdgeInsetsGeometry margin,
    double borderRadius,
    Widget widget, {
    Duration? duration,
    Color? backgroundColor,
  }) {
    final messengerState = ScaffoldMessenger.maybeOf(context);
    if (messengerState == null) {
      return;
    }

    messengerState.hideCurrentSnackBar();
    messengerState.showSnackBar(
      SnackBar(
        content: widget,
        duration: duration ?? DurationConstants.defaultSnackBarDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        margin: margin,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static void showAppSnackBarNewFeeds({
    required String title,
    bool isSuccess = true,
  }) {
    final messengerState = ScaffoldMessenger.maybeOf(Get.context!);
    if (messengerState == null) {
      return;
    }

    messengerState.hideCurrentSnackBar();
    messengerState.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isSuccess)
              AppIcon(
                icon: Assets.icons.createPostSuccess,
                color: AppColors.positive,
              )
            else
              const AppIcon(
                icon: Icons.remove_circle,
                color: AppColors.negative,
              ),
            AppSpacing.gapW12,
            Expanded(
                child: Text(
              title,
              style: AppTextStyles.s14w400.copyWith(color: AppColors.text2),
            )),
          ],
        ),
        duration: DurationConstants.defaultSnackBarDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static void hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) {
    return SystemChrome.setPreferredOrientations(orientations);
  }

  /// set status bar color & navigation bar color
  static void setSystemUIOverlayStyle(
    SystemUiOverlayStyle systemUiOverlayStyle,
  ) {
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  static Offset? getWidgetPosition(GlobalKey globalKey) {
    final renderBox =
        globalKey.currentContext?.findRenderObject() as RenderBox?;

    return renderBox?.localToGlobal(Offset.zero);
  }

  static double? getWidgetWidth(GlobalKey globalKey) {
    final renderBox =
        globalKey.currentContext?.findRenderObject() as RenderBox?;

    return renderBox?.size.width;
  }

  static double? getWidgetHeight(GlobalKey globalKey) {
    final renderBox =
        globalKey.currentContext?.findRenderObject() as RenderBox?;

    return renderBox?.size.height;
  }

  static Future<T?> showBottomSheet<T>({
    required Widget child,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    bool enableDrag = true,
    bool isDismissible = true,
    bool useRootNavigator = true,
    bool isScrollControlled = false,
    bool isFullScreen = false,
    double? heightFactor,
    RouteSettings? settings,
  }) {
    return Get.bottomSheet<T>(
      FractionallySizedBox(
        heightFactor: isFullScreen ? heightFactor ?? 0.9 : null,
        child: _bottomSheetWrapper(child: child),
      ),
      settings: settings,
      backgroundColor: AppColors.text1,
      barrierColor: Colors.black26,
      elevation: elevation,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
      clipBehavior: clipBehavior,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      isScrollControlled: isFullScreen || isScrollControlled,
    );
  }

  static Widget _bottomSheetWrapper({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.popup.withOpacity(0.22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: child,
        ),
      ),
    );
  }

  static Future<void> copyToClipboard(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }

  static void showRawToast(String message) {
    final snackBar = GetSnackBar(
      messageText: Text(
        message,
        style: AppTextStyles.s14w400.text2Color,
      ),
      backgroundColor: AppColors.white,
      borderRadius: Sizes.s8,
      margin: AppSpacing.edgeInsetsH20,
      animationDuration: const Duration(milliseconds: 500),
      duration: const Duration(seconds: 2),
    );

    Get.showSnackbar(snackBar);
  }

  static void showToast({
    required String title,
    required String message,
    Color backgroundColor = AppColors.white,
    VoidCallback? onTapped,
  }) {
    if (title.isEmpty || message.isEmpty) {
      return;
    }

    Get.closeCurrentSnackbar();

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      animationDuration: const Duration(milliseconds: 500),
      onTap: (_) {
        Get.closeCurrentSnackbar();
        onTapped?.call();
      },
      colorText: AppColors.text2,
    );
  }

  static Future<T?> showAppDialog<T>({
    required String title,
    required String message,
    Widget? icon,
    // negative
    String? negativeText,
    VoidCallback? onNegativePressed,
    Color? negativeColor,
    Color? negativeTextColor,
    // positive
    String? positiveText,
    VoidCallback? onPositivePressed,
    Color? positiveColor,
    Color? positiveTextColor,
    bool barrierDismissible = true,
  }) {
    return Get.dialog<T>(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: AppColors.opacityBackground,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Sizes.s24.w,
              vertical: Sizes.s40.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon,
                  AppSpacing.gapH28,
                ],
                Text(
                  title,
                  style: AppTextStyles.s18w500.text4Color,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.gapH12,
                Text(
                  message,
                  style: AppTextStyles.s16w500.text1Color,
                  textAlign: TextAlign.center,
                ),
                if (negativeText != null || positiveText != null) ...[
                  AppSpacing.gapH28,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (negativeText != null)
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              onNegativePressed?.call();
                              if (barrierDismissible) {
                                Get.back();
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: negativeColor,
                            ),
                            child: Text(
                              negativeText,
                              style: AppTextStyles.s18w500.toColor(
                                negativeTextColor ?? AppColors.text1,
                              ),
                            ),
                          ),
                        ),
                      if (negativeText != null && positiveText != null)
                        AppSpacing.gapW12,
                      if (positiveText != null)
                        Expanded(
                          child: AppButton.primary(
                            label: positiveText,
                            onPressed: () {
                              onPositivePressed?.call();
                              if (barrierDismissible) {
                                Get.back();
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black26,
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<T?> showSuccessDialog<T>({
    required String message,
    String? title,
    String? buttonText,
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
  }) {
    return showAppDialog<T>(
      title: title ?? Get.context!.l10n.global__success_title,
      message: message,
      barrierDismissible: barrierDismissible,
      icon: AppIcon(
        icon: AppIcons.checkBlur,
        size: Sizes.s56,
        color: AppColors.stoke,
      ),
      positiveText: buttonText ?? Get.context!.l10n.button__ok,
      onPositivePressed: onButtonPressed,
    );
  }

  static Future<T?> showActionSheet<T>({
    required List<ActionSheetItem> items,
    String? cancelText,
    Widget? title,
    Widget? message,
  }) {
    return showCupertinoModalPopup<T>(
      context: Get.context!,
      builder: (context) {
        return Theme(
          data: ThemeData.light(),
          child: CupertinoActionSheet(
            title: title,
            message: message,
            actions: [
              for (final item in items)
                CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                    item.onPressed?.call();
                  },
                  child: Text(
                    item.title,
                    style: AppTextStyles.s18w500.text2Color,
                  ),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: Get.back,
              child: Text(
                cancelText ?? Get.context!.l10n.button__cancel,
                style: AppTextStyles.s18w500.negativeColor,
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<T?> showAppCupertinoAlertDialog<T>({
    required String title,
    required String message,
    String? negativeText,
    VoidCallback? onNegativePressed,
    String? positiveText,
    VoidCallback? onPositivePressed,
  }) {
    return showCupertinoDialog<T>(
      context: Get.context!,
      builder: (context) {
        return Theme(
          data: ThemeData.light(),
          child: CupertinoAlertDialog(
            title: Text(
              title,
              style: AppTextStyles.s18w500.text2Color,
            ),
            content: Text(
              message,
              style: AppTextStyles.s14w500.text2Color,
            ),
            actions: [
              if (negativeText != null)
                CupertinoDialogAction(
                  onPressed: () {
                    onNegativePressed?.call();
                    Get.back();
                  },
                  child: Text(
                    negativeText,
                    style: AppTextStyles.s16w500.text2Color,
                  ),
                ),
              if (positiveText != null)
                CupertinoDialogAction(
                  onPressed: () {
                    onPositivePressed?.call();
                    Get.back();
                  },
                  child: Text(
                    positiveText,
                    style: AppTextStyles.s16w500.text2Color,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static void showImageDialog({
    String? imageUrl,
    File? imageFile,
    VoidCallback? onLongPress,
  }) {
    assert(imageUrl != null || imageFile != null);

    Get.generalDialog(
      barrierColor: Colors.black87,
      barrierDismissible: true,
      barrierLabel: imageFile?.path ?? imageUrl!,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Builder(
                  builder: (context) {
                    final mediaWidget = Center(
                      child: imageFile != null
                          ? Image(
                              image: FileImage(imageFile),
                              fit: BoxFit.fitWidth,
                            )
                          : AppNetworkImage(
                              imageUrl,
                              fit: BoxFit.contain,
                              imageBuilder: (context, imageProvider) => Image(
                                image: imageProvider,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                    );

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 1.sw,
                          height: 1.sh,
                        ).clickable(Get.back),
                        Dismissible(
                          key: Key(imageFile?.path ?? imageUrl!),
                          direction: DismissDirection.down,
                          onDismissed: (_) => Get.back(),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onLongPress: onLongPress,
                            child: mediaWidget,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  bottom: Sizes.s48.h,
                  left: 0,
                  right: 0,
                  child: AppIcon(
                    icon: AppIcons.close,
                    onTap: Get.back,
                    isCircle: true,
                    padding: AppSpacing.edgeInsetsAll8,
                    backgroundColor: Colors.white70,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showVideoDialog(
    String videoUrl, {
    bool isFile = false,
    VoidCallback? onLongPress,
  }) {
    Get.generalDialog(
      barrierColor: Colors.black87,
      barrierDismissible: true,
      barrierLabel: videoUrl,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Builder(builder: (context) {
                  final video = Center(
                    child: AppVideoPlayer(
                      videoUrl,
                      fit: BoxFit.fitWidth,
                      isFile: isFile,
                    ),
                  );

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 1.sw,
                        height: 1.sh,
                      ).clickable(Get.back),
                      Dismissible(
                        key: Key(videoUrl),
                        direction: DismissDirection.down,
                        onDismissed: (_) => Get.back(),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onLongPress: onLongPress,
                          child: video,
                        ),
                      ),
                    ],
                  );
                }),
                Positioned(
                  bottom: Sizes.s48.h,
                  left: 0,
                  right: 0,
                  child: AppIcon(
                    icon: AppIcons.close,
                    onTap: Get.back,
                    isCircle: true,
                    padding: AppSpacing.edgeInsetsAll8,
                    backgroundColor: Colors.white70,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ActionSheetItem {
  final String title;
  final VoidCallback? onPressed;

  const ActionSheetItem({
    required this.title,
    this.onPressed,
  });
}

enum SnackBarNewfeedType {
  success,
  fail,
}
