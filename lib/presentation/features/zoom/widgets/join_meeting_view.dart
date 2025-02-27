import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

import '../../../../core/all.dart';
import '../../../common_controller.dart/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../zoom_home_controller.dart';

class JoinMeetingView extends StatefulWidget {
  const JoinMeetingView({required this.idMeeting, super.key});
  final String idMeeting;

  @override
  State<JoinMeetingView> createState() => _JoinMeetingViewState();
}

class _JoinMeetingViewState extends State<JoinMeetingView> {
  // bool isEnableJoinMeeting = false;
  bool isEnableCamera = true;
  bool isEnableNoAudio = true;
  bool isEnableRecordMeeting = false;
  bool disableButton = true;

  TextEditingController idMettingController = TextEditingController();
  TextEditingController nameZoom = TextEditingController();
  String previousText = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // idMettingController.addListener(_formatIdmetting);
    final currentUser = Get.find<AppController>().lastLoggedUser!;
    nameZoom.text = currentUser.fullName;

    if (widget.idMeeting != '') {
      idMettingController.text = widget.idMeeting;
      setDisableButton(false);
    }
  }

  String validIdMeeting(String nickname) {
    if (nickname.isEmpty) {
      return context.l10n.field__idmeeting_error_empty;
    } else if (!ValidationUtil.isValidUsername(nickname)) {
      return context.l10n.profile__username_not_valid;
    }

    return '';
  }

  void setDisableButton(bool value) {
    setState(() {
      disableButton = value;
    });
  }

  void _formatIdmetting() {
    String text = idMettingController.text.replaceAll('-', '');
    if (text.length > 12) text = text.substring(0, 12);

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i != 0 && i % 4 == 0) formatted += '-';
      formatted += text[i];
    }

    // Kiểm tra nếu người dùng xóa ký tự cuối cùng
    if (idMettingController.text.length < previousText.length &&
        previousText.endsWith('-') &&
        !formatted.endsWith('-')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }

    previousText = formatted;

    idMettingController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      hideKeyboardWhenTouchOutside: true,
      appBar: CommonAppBar(
        onLeadingPressed: () {
          if (widget.idMeeting == '') {
            Get.back();
          } else {
            Navigator.of(context).pop();
          }
        },
        titleType: AppBarTitle.none,
        titleWidget: Text(
          context.l10n.zoom__join_meeting,
          style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
        ).clickable(() => Get.back()),
        leadingIconColor: AppColors.text2,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.edgeInsetsAll20,
          child: Column(
            children: [
              inputMeetingIdWidget(),
              AppSpacing.gapH28,
              optionWidget(),
              AppSpacing.gapH28,
              starMeetingButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputMeetingIdWidget() {
    return Container(
      padding: AppSpacing.edgeInsetsAll20,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff97B9DE)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: idMettingController,
            hintText: context.l10n.zoom__hint_id,
            hintStyle: AppTextStyles.s16w500.subText2Color,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(0),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (validIdMeeting(value!).isNotEmpty) {
                return validIdMeeting(value);
              }

              return null;
            },
            onChanged: (value) {
              if (validIdMeeting(value).isEmpty) {
                if (nameZoom.text.isNotEmpty &&
                    idMettingController.text.isNotEmpty) {
                  setDisableButton(false);
                } else {
                  setDisableButton(true);
                }
              } else {
                setDisableButton(true);
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
            controller: nameZoom,
            hintText: context.l10n.zoom__hint_name,
            hintStyle: AppTextStyles.s16w500.subText2Color,
            border: InputBorder.none,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              if (validIdMeeting(idMettingController.text).isEmpty) {
                if (nameZoom.text.isNotEmpty &&
                    idMettingController.text.isNotEmpty) {
                  setDisableButton(false);
                } else {
                  setDisableButton(true);
                }
              } else {
                setDisableButton(true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget optionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.zoom__option,
          style: AppTextStyles.s16w600.text1Color,
        ),
        AppSpacing.gapH8,
        Container(
          padding: AppSpacing.edgeInsetsAll20,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff97B9DE)),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.zoom__toggle_camera,
                    style: AppTextStyles.s16w500
                        .copyWith(color: AppColors.zambezi),
                  ),
                  CupertinoSwitch(
                      activeColor: AppColors.blue10,
                      trackColor: AppColors.subText2,
                      value: isEnableCamera,
                      onChanged: (value) {
                        setState(() {
                          isEnableCamera = !isEnableCamera;
                        });
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
                    context.l10n.zoom__toggle_mic,
                    style: AppTextStyles.s16w500
                        .copyWith(color: AppColors.zambezi),
                  ),
                  CupertinoSwitch(
                    activeColor: AppColors.blue10,
                    trackColor: AppColors.subText2,
                    value: isEnableNoAudio,
                    onChanged: (value) {
                      setState(() {
                        isEnableNoAudio = !isEnableNoAudio;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget starMeetingButton() {
    return AppButton.primary(
      onPressed: () {
        ViewUtil.hideKeyboard(context);
        final jitsiMeet = JitsiMeet();
        final configOverrides = {
          'startWithAudioMuted': isEnableNoAudio,
          'startWithVideoMuted': isEnableCamera,
          'subject': 'XIN Zoom',
        };
        final currentUser = Get.find<AppController>().lastLoggedUser!;
        final options = JitsiMeetConferenceOptions(
          serverURL: Get.find<EnvConfig>().jitsiUrl,
          room: idMettingController.text.trim(),
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
                      displayName: nameZoom.text,
                      email: currentUser.email ?? currentUser.phone ?? '',
                      avatar: currentUser.avatarPath ?? '',
                    )
                  : JitsiMeetUserInfo(
                      displayName: nameZoom.text,
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
            idMettingController.text.trim(), DateTime.now().toString(), 'join');
      },
      width: double.infinity,
      label: context.l10n.zoom__join_meeting,
      isDisabled: disableButton,
      // color: AppColors.button5,
    );
  }
}
