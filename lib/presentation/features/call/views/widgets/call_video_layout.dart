import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit/controllers/rtc_buttons.dart';
import 'package:agora_uikit/models/agora_settings.dart';
import 'package:agora_uikit/src/layout/floating_layout.dart';
import 'package:agora_uikit/src/layout/widgets/disabled_video_widget.dart';
import 'package:easy_count_timer/easy_count_timer.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/agora_voice_client.dart';
import '../../../../../models/all.dart';
import 'grid_layout.dart';

/// A UI class to style how the video layout looks like. Use this class to choose between the two default layouts [FloatingLayout] and [GridLayout], enable active speaker, display number of users, display mic and video state of the user.
class CallVideoLayoutViewer extends StatefulWidget {
  final bool isTranslate;

  final AgoraCustomClient client;

  /// Set the height of the container in the floating view. The default height is 0.2 of the total height.
  final double? floatingLayoutContainerHeight;

  /// Set the width of the container in the floating view. The default width is 1/3 of the total width.
  final double? floatingLayoutContainerWidth;

  /// Padding of the main user or the active speaker in the floating layout.
  final EdgeInsets floatingLayoutMainViewPadding;

  /// Padding of the secondary user present in the list.
  final EdgeInsets floatingLayoutSubViewPadding;

  /// Widget that will be displayed when the local or remote user has disabled it's video.
  final Widget userLocalView;

  /// Display the camera and microphone status of a user. This feature is only available in the [Layout.floating]
  final bool showAVState;

  final bool enableHostControls;

  /// Display the total number of users in a channel.
  final bool showNumberOfUsers;

  /// Render mode for local and remote video
  final RenderModeType renderModeType;

  final Map<int, User> users;

  /// controller for count up time
  final CountTimerController countTimerController;

  final Widget Function() callStatusWidget;

  const CallVideoLayoutViewer({
    required this.isTranslate,
    required this.client,
    required this.users,
    required this.countTimerController,
    required this.callStatusWidget,
    Key? key,
    this.floatingLayoutContainerHeight,
    this.floatingLayoutContainerWidth,
    this.floatingLayoutMainViewPadding = const EdgeInsets.fromLTRB(3, 0, 3, 3),
    this.floatingLayoutSubViewPadding = const EdgeInsets.fromLTRB(3, 3, 0, 3),
    this.userLocalView = const DisabledVideoWidget(),
    this.showAVState = false,
    this.enableHostControls = false,
    this.showNumberOfUsers = false,
    this.renderModeType = RenderModeType.renderModeHidden,
  }) : super(key: key);

  @override
  State<CallVideoLayoutViewer> createState() => _CallVideoLayoutViewerState();
}

class _CallVideoLayoutViewerState extends State<CallVideoLayoutViewer> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.client.sessionController,
      builder: (BuildContext context, AgoraSettings value, Widget? child) {
        if (!widget.client.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: GridLayout(
            client: widget.client,
            showNumberOfUsers: widget.showNumberOfUsers,
            localUserView: widget.userLocalView,
            renderModeType: widget.renderModeType,
            users: widget.users,
            countTimerController: widget.countTimerController,
            callStatusWidget: widget.callStatusWidget,
            isTranslate: widget.isTranslate,
          ),
          onTap: () {
            toggleVisible(
              value: value,
            );
          },
        );
      },
    );
  }
}
