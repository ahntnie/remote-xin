import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/extensions/call_session_controller_ext.dart';
import '../../../../../core/utils/agora_voice_client.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/gen/assets.gen.dart';
import '../../../../resource/styles/styles.dart';
import '../../controllers/rtc_buttons.dart';
import '../../enums/built_in_buttons_enum.dart';
import 'call_action_button.dart';

/// A UI class to style how the buttons look. Use this class to add, remove or customize the buttons in your live video calling application.
class CallActionButtonsWidget extends StatefulWidget {
  const CallActionButtonsWidget({
    required this.client,
    Key? key,
    this.enabledButtons,
    this.extraButtons,
    this.autoHideButtons,
    this.autoHideButtonTime = 5,
    this.verticalButtonPadding,
    this.buttonAlignment = Alignment.bottomCenter,
    this.disconnectButtonChild,
    this.muteButtonChild,
    this.switchCameraButtonChild,
    this.disableVideoButtonChild,
    this.screenSharingButtonWidget,
    this.cloudRecordingButtonWidget,
    this.onDisconnect,
    this.addScreenSharing = false,
    this.cloudRecordingEnabled = false,
    this.muteSpeakerButtonChild,
    this.chatButtonWidget,
  }) : super(key: key);
  final AgoraCustomClient client;

  /// List of enabled buttons. Use this to remove any of the default button or change their order.
  final List<BuiltInButtons>? enabledButtons;

  /// List of buttons that are added next to the default buttons. The buttons class contains a horizontal scroll view.
  final List<Widget>? extraButtons;

  /// Automatically hides the button class after a default time of 5 seconds if not set otherwise.
  final bool? autoHideButtons;

  /// The default auto hide time = 5 seconds
  final int autoHideButtonTime;

  /// Adds a vertical padding to the set of button
  final double? verticalButtonPadding;

  /// Alignment for the button class
  final Alignment buttonAlignment;

  /// Use this to style the disconnect button as per your liking while still keeping the default functionality.
  final Widget? disconnectButtonChild;

  /// Use this to style the mute mic button as per your liking while still keeping the default functionality.
  final Widget? muteButtonChild;

  /// Use this to style the mute speaker button as per your liking while still keeping the default functionality.
  final Widget? muteSpeakerButtonChild;

  /// Use this to style the switch camera button as per your liking while still keeping the default functionality.
  final Widget? switchCameraButtonChild;

  /// Use this to style the disabled video button as per your liking while still keeping the default functionality.
  final Widget? disableVideoButtonChild;

  final Widget? screenSharingButtonWidget;

  final Widget? cloudRecordingButtonWidget;
  final Widget? chatButtonWidget;

  /// Agora VideoUIKit takes care of leaving the channel and destroying the engine. But if you want to add any other functionality to the disconnect button, use this.
  final Function()? onDisconnect;

  /// Adds Screen Sharing button to the layout and let's user share their screen using the same. Currently only on Android and iOS. The deafult value is set to `false`. So, if you want to add screen sharing set [addScreenSharing] to `true`.
  ///
  /// Note: This feature is currently in beta
  final bool? addScreenSharing;

  final bool? cloudRecordingEnabled;

  @override
  State<CallActionButtonsWidget> createState() =>
      _CallActionButtonsWidgetState();
}

class _CallActionButtonsWidgetState extends State<CallActionButtonsWidget> {
  List<Widget> buttonsEnabled = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: widget.autoHideButtonTime),
      () {
        if (mounted) {
          setState(() {
            toggleVisible(
              sessionController: widget.client.sessionController,
            );
          });
        }
      },
    );

    final Map buttonMap = <BuiltInButtons, Widget>{
      BuiltInButtons.toggleMic: _muteMicButton(),
      BuiltInButtons.callEnd: _disconnectCallButton(),
      BuiltInButtons.switchCamera: _switchCameraButton(),
      BuiltInButtons.toggleCamera: _disableVideoButton(),
      BuiltInButtons.toggleSpeaker: _muteSpeakerButton(),
    };

    if (widget.enabledButtons != null) {
      for (var i = 0; i < widget.enabledButtons!.length; i++) {
        for (var j = 0; j < buttonMap.length; j++) {
          if (buttonMap.keys.toList()[j] == widget.enabledButtons![i]) {
            buttonsEnabled.add(buttonMap.values.toList()[j]);
          }
        }
      }
    }
  }

  Widget toolbar(List<Widget>? buttonList) {
    return Container(
      alignment: widget.buttonAlignment,
      padding: widget.verticalButtonPadding == null
          ? const EdgeInsets.only(bottom: Sizes.s24)
          : EdgeInsets.symmetric(
              vertical: widget.verticalButtonPadding!,
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 1.sw - 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: 1.sw - 40,
                child: widget.enabledButtons == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _disableVideoButton(),
                          _muteMicButton(),
                          _muteSpeakerButton(),
                          _switchCameraButton(),
                          _chatButton(),
                          if (widget.extraButtons != null)
                            for (var i = 0;
                                i < widget.extraButtons!.length;
                                i++)
                              widget.extraButtons![i],
                          _disconnectCallButton(),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.enabledButtons!
                              .contains(BuiltInButtons.toggleCamera))
                            _disableVideoButton(),
                          if (widget.enabledButtons!
                              .contains(BuiltInButtons.toggleMic))
                            _muteMicButton(),
                          if (widget.enabledButtons!
                              .contains(BuiltInButtons.switchCamera))
                            _switchCameraButton(),
                          if (widget.enabledButtons!
                              .contains(BuiltInButtons.toggleSpeaker))
                            _muteSpeakerButton(),
                          if (widget.enabledButtons!
                              .contains(BuiltInButtons.chat))
                            _chatButton(),
                          if (widget.extraButtons != null)
                            for (var i = 0;
                                i < widget.extraButtons!.length;
                                i++)
                              widget.extraButtons![i],
                          if (widget.enabledButtons!
                              .contains(BuiltInButtons.callEnd))
                            _disconnectCallButton(),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _muteMicButton() {
    return widget.muteButtonChild != null
        ? RawMaterialButton(
            onPressed: () => toggleMute(
              sessionController: widget.client.sessionController,
            ),
            child: widget.muteButtonChild,
          )
        : CallActionButton(
            turnOn: widget.client.sessionController.value.isLocalUserMuted,
            onPressed: () => toggleMute(
                  sessionController: widget.client.sessionController,
                ),
            child: AppIcon(
              icon: widget.client.sessionController.value.isLocalUserMuted
                  ? AppIcons.micOff
                  : AppIcons.micOn,
              color: widget.client.sessionController.value.isLocalUserMuted
                  ? AppColors.blue10
                  : AppColors.text2,
            )
            // Icon(
            //   widget.client.sessionController.value.isLocalUserMuted
            //       ? Icons.mic_off_outlined
            //       : Icons.mic_outlined,
            //   size: 24.0,
            //   color: Colors.black,
            // ),
            );
  }

  Widget _muteSpeakerButton() {
    return widget.muteSpeakerButtonChild != null
        ? RawMaterialButton(
            onPressed: () => toggleSpeaker(
              sessionController: widget.client.sessionController,
            ),
            child: widget.muteButtonChild,
          )
        : CallActionButton(
            turnOn: !widget.client.sessionController.isInternalSpeaker(),
            onPressed: () => toggleSpeaker(
                  sessionController: widget.client.sessionController,
                ),
            child: AppIcon(
              icon: AppIcons.speaker,
              color: !widget.client.sessionController.isInternalSpeaker()
                  ? AppColors.blue10
                  : AppColors.text2,
              size: 28,
            )
            // Icon(
            //   widget.client.sessionController.isInternalSpeaker()
            //       ? Icons.volume_down
            //       : Icons.volume_up_rounded,
            //   size: 24.0,
            //   color: Colors.black,
            // ),
            );
  }

  Widget _disconnectCallButton() {
    return widget.disconnectButtonChild != null
        ? RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: widget.disconnectButtonChild,
          )
        : CallActionButton(
            onPressed: () => _onCallEnd(context),
            fillColor: AppColors.negative2,
            child:
                const Icon(Icons.close, color: Colors.white, size: Sizes.s24),
          );
  }

  Widget _switchCameraButton() {
    return widget.switchCameraButtonChild != null
        ? RawMaterialButton(
            onPressed: () => switchCamera(
              sessionController: widget.client.sessionController,
            ),
            child: widget.switchCameraButtonChild,
          )
        : CallActionButton(
            onPressed: () => switchCamera(
              sessionController: widget.client.sessionController,
            ),
            child: const Icon(
              Icons.switch_camera,
              color: Colors.black,
              size: 20.0,
            ),
          );
  }

  Widget _disableVideoButton() {
    return widget.disableVideoButtonChild != null
        ? RawMaterialButton(
            onPressed: () => toggleCamera(
              sessionController: widget.client.sessionController,
            ),
            child: widget.disableVideoButtonChild,
          )
        : CallActionButton(
            turnOn: !widget.client.sessionController.value.isLocalVideoDisabled,
            onPressed: () => toggleCamera(
                  sessionController: widget.client.sessionController,
                ),
            child: AppIcon(
              icon: widget.client.sessionController.value.isLocalVideoDisabled
                  ? AppIcons.videoOff
                  : AppIcons.videoOn,
              color: !widget.client.sessionController.value.isLocalVideoDisabled
                  ? AppColors.blue10
                  : AppColors.text2,
            )
            // Icon(
            //   widget.client.sessionController.value.isLocalVideoDisabled
            //       ? Icons.videocam_off
            //       : Icons.videocam,
            //   color: Colors.black,
            //   size: 20.0,
            // ),
            );
  }

  /// Default functionality of disconnect button is such that it pops the view and navigates the user to the previous screen.
  Future<void> _onCallEnd(BuildContext context) async {
    if (widget.onDisconnect != null) {
      await widget.onDisconnect!();
    } else {
      Navigator.pop(context);
    }
    await widget.client.release();
  }

  Widget _chatButton() {
    return widget.chatButtonWidget != null
        ? RawMaterialButton(
            onPressed: () => chat(
              sessionController: widget.client.sessionController,
            ),
            child: widget.chatButtonWidget,
          )
        : CallActionButton(
            onPressed: () => chat(
              sessionController: widget.client.sessionController,
            ),
            child: Assets.icons.chat.svg(width: 20, color: Colors.black),
          );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.client.sessionController,
      builder: (context, counter, something) {
        return widget.autoHideButtons != null
            ? widget.autoHideButtons!
                ? Visibility(
                    visible: widget.client.sessionController.value.visible,
                    child: toolbar(
                      widget.enabledButtons == null ? null : buttonsEnabled,
                    ),
                  )
                : toolbar(widget.enabledButtons == null ? null : buttonsEnabled)
            : toolbar(widget.enabledButtons == null ? null : buttonsEnabled);
      },
    );
  }
}
