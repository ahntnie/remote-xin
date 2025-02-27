import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../common_widgets/app_icon.dart';
import '../../../../common_widgets/app_qr_code.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../../../resource/styles/gaps.dart';
import '../../../../resource/styles/text_styles.dart';
import '../../../chat/conversation_details/views/widgets/setting_group_widget.dart';
import '../../all.dart';

class InviteChatLinkAndRefID extends StatefulWidget {
  final PersonalPageController controller;

  const InviteChatLinkAndRefID({
    required this.controller,
    super.key,
  });

  @override
  State<InviteChatLinkAndRefID> createState() => _InviteChatLinkAndRefIDState();
}

class _InviteChatLinkAndRefIDState extends State<InviteChatLinkAndRefID> {
  // late Future<String> _getSharedLinkFuture;

  late String _sharedLink;

  @override
  void initState() {
    super.initState();

    // _getSharedLinkFuture = widget.controller.getSharedLink();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInviteLink(),
        AppSpacing.gapH16,
        _buildReferralCode(),
      ],
    );
  }

  FutureBuilder<String> _buildInviteLink() {
    return FutureBuilder<String>(
      future: widget.controller.getSharedLink(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return AppSpacing.emptyBox;
        }

        _sharedLink = snapshot.data!;

        return SettingGroupWidget(
          groupName: context.l10n.conversation_details__invite_link,
          children: [
            SettingItem(
              icon: AppIcons.link,
              title: snapshot.data!,
              trailing: Row(
                children: [
                  AppIcon(
                    icon: Icons.qr_code,
                    size: Sizes.s20,
                    padding: AppSpacing.edgeInsetsAll8,
                    onTap: _showQRCodeDialog,
                    color: Colors.black,
                  ),
                  AppIcon(
                    icon: AppIcons.copy,
                    color: Colors.black,
                    size: Sizes.s20,
                    padding: AppSpacing.edgeInsetsAll8.copyWith(
                      right: 0,
                    ),
                    onTap: () {
                      ViewUtil.copyToClipboard(snapshot.data!).then((_) {
                        ViewUtil.showAppSnackBarNewFeeds(
                          title: context.l10n.global__copied_to_clipboard,
                        );
                      });
                    },
                  ),
                ],
              ),
              onTap: _showQRCodeDialog,
            ),
          ],
        );
      },
    );
  }

  void _showQRCodeDialog() {
    Get.dialog(
      barrierColor: Colors.black26,
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
                Text(
                  _sharedLink,
                  style: AppTextStyles.s16w500.text1Color,
                ),
                AppSpacing.gapH16,
                AppQrCodeView(
                  _sharedLink,
                  size: 300.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralCode() {
    final referralId = widget.controller.currentUser.webUserId ?? '';

    if (referralId.isEmpty) {
      return AppSpacing.emptyBox;
    }

    return SettingGroupWidget(
      groupName: context.l10n.profile__referral_id_label,
      children: [
        SettingItem(
          title: referralId,
          trailing: AppIcon(
            icon: AppIcons.copy,
            size: Sizes.s20,
            color: Colors.black,
            padding: AppSpacing.edgeInsetsAll8,
            onTap: () {
              ViewUtil.copyToClipboard(referralId).then(
                (_) {
                  ViewUtil.showAppSnackBarNewFeeds(
                    title: context.l10n.global__copied_to_clipboard,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
