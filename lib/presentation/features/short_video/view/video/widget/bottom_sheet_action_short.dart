import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../../../core/extensions/all.dart';
import '../../../../../resource/resource.dart';
import 'bottom_sheet_indicator.dart';
import 'icon_button_action.dart';

class BottomSheetActionShort {
  static Future<void> showBottomSheetAction({
    required BuildContext context,
    required VoidCallback onSaved,
    required VoidCallback onPin,
    required VoidCallback onDownload,
    required VoidCallback onReport,
    required VoidCallback onDelete,
    required VoidCallback onEdit,
    required bool isMyVideo,
    required bool isPinned,
    required bool isSaved,
    required bool isShowDelete,
  }) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => Material(
        child: SizedBox(
          height: 0.1.sh +
              _buildPrimaryActions(context, isMyVideo, isPinned, isSaved,
                          onSaved, onPin, onEdit)
                      .length *
                  60.0 +
              _buildSecondaryActions(context, isMyVideo, onDownload, onDelete,
                          onReport, isShowDelete)
                      .length *
                  50.0,
          child: Container(
            color: const Color(0xfff2f3f7),
            child: Column(
              children: [
                AppSpacing.gapH12,
                BottomSheetIndicator(),
                AppSpacing.gapH20,
                _buildActionItems(
                  context,
                  isMyVideo,
                  isPinned,
                  isSaved,
                  isShowDelete,
                  onSaved,
                  onPin,
                  onDownload,
                  onReport,
                  onDelete,
                  onEdit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildActionItems(
    BuildContext context,
    bool isMyVideo,
    bool isPinned,
    bool isSaved,
    bool isShowDelete,
    VoidCallback onSaved,
    VoidCallback onPin,
    VoidCallback onDownload,
    VoidCallback onReport,
    VoidCallback onDelete,
    VoidCallback onEdit,
  ) {
    final primaryActions = _buildPrimaryActions(
      context,
      isMyVideo,
      isPinned,
      isSaved,
      onSaved,
      onPin,
      onEdit,
    );

    final secondaryActions = _buildSecondaryActions(
        context, isMyVideo, onDownload, onDelete, onReport, isShowDelete);

    if (!isMyVideo && secondaryActions.length <= 3) {
      return _buildContainerWidget(
        context,
        primaryActions + secondaryActions,
      );
    }

    return Column(
      children: [
        _buildContainerWidget(
          context,
          primaryActions,
        ),
        AppSpacing.gapH16,
        _buildContainerWidget(
          context,
          secondaryActions,
        ),
      ],
    );
  }

  static List<Widget> _buildPrimaryActions(
    BuildContext context,
    bool isMyVideo,
    bool isPinned,
    bool isSaved,
    VoidCallback onSaved,
    VoidCallback onPin,
    VoidCallback onEdit,
  ) {
    return [
      if (isMyVideo)
        IconButtonAction(
          icon: isPinned ? Assets.icons.unpin : Assets.icons.pin,
          onPressed: onPin,
          title: isPinned
              ? context.l10n.unpin_this_video
              : '${context.l10n.button__pin_message} video',
          content: isPinned
              ? context.l10n.unpin_this_video_desc
              : context.l10n.pin_this_video,
        ),
      // IconButtonAction(
      //   icon: isSaved ? Assets.icons.bookmarkFill : Assets.icons.unBookmarkFill,
      //   onPressed: onSaved,
      //   title: isSaved
      //       ? context.l10n.unsave_this_video
      //       : '${context.l10n.button__save} video',
      //   content: isSaved
      //       ? context.l10n.unsave_this_video_desc
      //       : context.l10n.add_to_bookmark,
      // ),
      // if (isMyVideo)
      //   IconButtonAction(
      //     icon: Assets.icons.edit,
      //     onPressed: onEdit,
      //     title: '${context.l10n.edit} video',
      //     content: context.l10n.edit_your_video,
      //   ),
    ];
  }

  static List<Widget> _buildSecondaryActions(
    BuildContext context,
    bool isMyVideo,
    VoidCallback onDownload,
    VoidCallback onDelete,
    VoidCallback onReport,
    bool isShowDelete,
  ) {
    return [
      IconButtonAction(
        icon: Assets.icons.download,
        onPressed: onDownload,
        title: context.l10n.button__download,
        content: context.l10n.download_this_video,
      ),
      if (isMyVideo && isShowDelete)
        IconButtonAction(
          icon: Assets.icons.delete,
          onPressed: onDelete,
          colorIcon: AppColors.negative,
          colorText: AppColors.negative,
          colorContent: AppColors.negative,
          title: context.l10n.button__delete,
          content: context.l10n.delete_this_video_out_of_your_list,
        ),
      if (!isMyVideo)
        IconButtonAction(
          icon: Assets.icons.report,
          onPressed: onReport,
          colorIcon: AppColors.negative,
          colorText: AppColors.negative,
          colorContent: AppColors.negative,
          title: context.l10n.button__report,
          content: context.l10n.report_this_video,
        ),
    ];
  }

  static Widget _buildContainerWidget(
    BuildContext context,
    List<Widget> listIconButtonAction,
  ) {
    return IntrinsicHeight(
      child: Container(
        width: 0.95.sw,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (var item in listIconButtonAction) ...[
                item,
                AppSpacing.gapH8,
              ]
            ],
          ),
        ),
      ),
    );
  }
}
