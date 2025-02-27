import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

import '../../../../core/all.dart';
import '../../../base/base_view.dart';
import '../../../common_controller.dart/app_controller.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/styles/app_colors.dart';
import '../../../resource/styles/gaps.dart';
import '../../../resource/styles/text_styles.dart';
import '../../chat/conversation_details/views/widgets/all.dart';
import '../zoom_home_controller.dart';

class StartMeetingView extends BaseView<ZoomHomeController> {
  const StartMeetingView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    final idMeeting = Get.find<AppController>().lastLoggedUser!.zoomId;

    return CommonScaffold(
      hideKeyboardWhenTouchOutside: true,
      appBar: CommonAppBar(
        titleType: AppBarTitle.none,
        titleWidget: Text(
          l10n.zoom__start_meeting,
          style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
        ).clickable(() => Get.back()),
        leadingIconColor: AppColors.text2,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: AppSpacing.edgeInsetsAll20,
          child: Column(
            children: [
              linkWidget(idMeeting ?? '', context),
              AppSpacing.gapH12,
              // Obx(() => controller.sharedLink.value != ''
              //     ? _buildInviteLink(context)
              //     : AppSpacing.emptyBox),
              AppSpacing.gapH28,
              optionWidget(),
              AppSpacing.gapH28,
              Obx(() => starMeetingButton(idMeeting ?? '', context)),
              AppSpacing.gapH24,
            ],
          ),
        ),
      ),
    );
  }

  Widget linkWidget(String idMeeting, BuildContext context) {
    return Container(
      padding: AppSpacing.edgeInsetsAll20,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff97B9DE)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          // Row(
          //   children: [
          //     Text(
          //       '${l10n.zoom__hint_id}: $idMeeting',
          //       style: AppTextStyles.s16w600,
          //     ),
          //     const Spacer(),
          //     const AppIcon(
          //       icon: Icons.copy,
          //       size: 20,
          //     ).clickable(() {
          //       ViewUtil.copyToClipboard(idMeeting).then((_) {
          //         ViewUtil.showAppSnackBar(
          //           context,
          //           context.l10n.global__copied_to_clipboard,
          //         );
          //       });
          //     })
          //   ],
          // ),
          AppTextField(
            controller: controller.meetingIdController,
            hintText: context.l10n.zoom__hint_id,
            hintStyle: AppTextStyles.s16w500.subText2Color,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(0),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (controller.validIdMeeting(value!).isNotEmpty) {
                return controller.validIdMeeting(value);
              }

              return null;
            },
            onChanged: (value) {
              if (controller.validIdMeeting(value).isEmpty) {
                if (controller.nameZoom.text.isNotEmpty &&
                    controller.meetingIdController.text.isNotEmpty) {
                  controller.setDisableButton(false);
                } else {
                  controller.setDisableButton(true);
                }
              } else {
                controller.setDisableButton(true);
              }
            },
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
          AppSpacing.gapH16,
          const Divider(height: 1, color: Color(0xff97B9DE)),
          AppSpacing.gapH16,
          AppTextField(
            controller: controller.nameZoom,
            hintText: l10n.zoom__hint_name,
            hintStyle: AppTextStyles.s16w500.subText2Color,
            border: InputBorder.none,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              if (controller
                  .validIdMeeting(controller.meetingIdController.text)
                  .isEmpty) {
                if (controller.nameZoom.text.isNotEmpty &&
                    controller.meetingIdController.text.isNotEmpty) {
                  controller.setDisableButton(false);
                } else {
                  controller.setDisableButton(true);
                }
              } else {
                controller.setDisableButton(true);
              }
            },
          )
        ],
      ),
    );
  }

  Widget optionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.zoom__option,
          style: AppTextStyles.s16w600.text1Color,
        ),
        AppSpacing.gapH8,
        Container(
            padding: AppSpacing.edgeInsetsAll20,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff97B9DE)),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Obx(
              () => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.zoom__toggle_camera,
                        style: AppTextStyles.s16w500
                            .copyWith(color: AppColors.zambezi),
                      ),
                      CupertinoSwitch(
                          activeColor: AppColors.blue10,
                          trackColor: AppColors.subText2,
                          value: controller.isEnableCamera.value,
                          onChanged: (value) {
                            controller.isEnableCamera.toggle();
                          }),
                    ],
                  ),
                  AppSpacing.gapH16,
                  const Divider(height: 1, color: Color(0xff97B9DE)),
                  AppSpacing.gapH16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.zoom__toggle_mic,
                        style: AppTextStyles.s16w500
                            .copyWith(color: AppColors.zambezi),
                      ),
                      CupertinoSwitch(
                        activeColor: AppColors.blue10,
                        trackColor: AppColors.subText2,
                        value: controller.isEnableNoAudio.value,
                        onChanged: (value) {
                          controller.isEnableNoAudio.toggle();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildInviteLink(BuildContext context) {
    return SettingGroupWidget(
      groupName: context.l10n.conversation_details__invite_link,
      children: [
        SettingItem(
          icon: AppIcons.link,
          title: controller.sharedLink.value,
          trailing: Row(
            children: [
              AppIcon(
                icon: Icons.qr_code,
                size: Sizes.s20,
                padding: AppSpacing.edgeInsetsAll8,
                onTap: _showQRCodeDialog,
              ),
              AppIcon(
                icon: AppIcons.copy,
                size: Sizes.s20,
                padding: AppSpacing.edgeInsetsAll8.copyWith(right: 0),
                onTap: () {
                  ViewUtil.copyToClipboard(controller.sharedLink.value)
                      .then((_) {
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
                  controller.sharedLink.value,
                  // style: AppTextStyles.s16w500.text5Color,
                ),
                AppSpacing.gapH16,
                AppQrCodeView(
                  controller.sharedLink.value,
                  size: 300.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget starMeetingButton(String idMeeting, BuildContext context) {
    return AppButton.primary(
      onPressed: () {
        ViewUtil.hideKeyboard(context);
        final jitsiMeet = JitsiMeet();
        final configOverrides = {
          'startWithAudioMuted': controller.isEnableNoAudio.value,
          'startWithVideoMuted': controller.isEnableCamera.value,
          'subject': 'XIN Zoom',
        };
        // if (!isCreatorOrAdmin) {
        //   configOverrides['buttonsWithNotifyClick'] = ['end-meeting'];
        // }
        final currentUser = Get.find<AppController>().lastLoggedUser!;
        final options = JitsiMeetConferenceOptions(
          serverURL: Get.find<EnvConfig>().jitsiUrl,
          room: controller.meetingIdController.text.trim(),
          configOverrides: configOverrides,
          featureFlags: {
            'unsaferoomwarning.enabled': false,
            FeatureFlags.preJoinPageEnabled: false,
            // 'ios.recording.enabled': true,
            'ios.screensharing.enabled': true,
            'recording.enabled': true,
            'meeting-password.enabled': true,
            'toolbox.enabled': true,
            'toolbox.alwaysVisible': true,
          },
          userInfo:
              currentUser.avatarPath != null && currentUser.avatarPath != ''
                  ? JitsiMeetUserInfo(
                      displayName: controller.nameZoom.text,
                      email: currentUser.email ?? currentUser.phone ?? '',
                      avatar: currentUser.avatarPath ?? '',
                    )
                  : JitsiMeetUserInfo(
                      displayName: controller.nameZoom.text,
                      email: currentUser.email ?? currentUser.phone ?? '',
                    ),
        );

        // final listener = JitsiMeetEventListener(
        //   conferenceTerminated: (url, error) {
        //     debugPrint('conferenceTerminated: url: $url, error: $error');
        //     Get.back();
        //   },
        // );

        jitsiMeet.join(options);
        Get.find<ZoomHomeController>().addMeetingHistoryItem(
            controller.meetingIdController.text,
            DateTime.now().toString(),
            'new');
      },
      width: double.infinity,
      label: l10n.zoom__start_meeting,
      // color: AppColors.button5,
      textStyleLabel: AppTextStyles.s18w500.copyWith(
        color: Colors.white,
      ),
      isDisabled: controller.disableButton.value,
    );
  }
}
