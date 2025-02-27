import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit/models/agora_user.dart';
import 'package:agora_uikit/src/layout/widgets/disabled_video_widget.dart';
import 'package:easy_count_timer/easy_count_timer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../models/all.dart';
import '../../../../common_controller.dart/all.dart';
import '../../../../resource/gen/assets.gen.dart';
import '../../controllers/rtc_buttons.dart';
import 'info_user_widget.dart';

class GridLayout extends StatefulWidget {
  final bool isTranslate;

  final AgoraClient client;

  /// Display the total number of users in a channel.
  final bool? showNumberOfUsers;

  /// Widget that will be displayed when the local or remote user has disabled it's video.
  final Widget? localUserView;

  /// Render mode for local and remote video
  final RenderModeType renderModeType;

  final Map<int, User> users;

  /// controller for count up time
  final CountTimerController countTimerController;

  final Widget Function() callStatusWidget;

  const GridLayout({
    required this.isTranslate,
    required this.client,
    required this.countTimerController,
    required this.callStatusWidget,
    required this.users,
    Key? key,
    this.showNumberOfUsers,
    this.localUserView = const DisabledVideoWidget(),
    this.renderModeType = RenderModeType.renderModeHidden,
  }) : super(key: key);

  @override
  State<GridLayout> createState() => _GridLayoutState();
}

class _GridLayoutState extends State<GridLayout> {
  final appController = Get.find<AppController>();

  List<Widget> _getRenderViews(List<AgoraUser> users) {
    final List<StatefulWidget> list = [];

    for (AgoraUser user in users) {
      if (user.clientRoleType == ClientRoleType.clientRoleBroadcaster) {
        if (user.videoDisabled == false) {
          list.add(
            AgoraVideoView(
              onAgoraVideoViewCreated: (viewId) {
                print('AgoraVideoView created: $viewId');
              },
              controller: VideoViewController.remote(
                rtcEngine: widget.client.sessionController.value.engine!,
                canvas: VideoCanvas(
                  uid: user.uid,
                  renderMode: widget.renderModeType,
                ),
                connection: RtcConnection(
                  channelId: widget.client.sessionController.value
                      .connectionData!.channelName,
                ),
              ),
            ),
          );
          continue;
        }
        list.add(
          DisabledVideoStfWidget(
            disabledVideoWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InfoUserWidget(
                  user: widget.users[user.uid],
                  isTranslate: widget.isTranslate,
                ),
                widget.callStatusWidget(),
              ],
            ),
          ),
        );
      }
    }

    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();

    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget _viewGrid() {
    final users = widget.client.sessionController.value.users;
    if (users.isEmpty) {
      return widget.localUserView!;
    }
    final views = _getRenderViews(users);
    if (views.isEmpty) {
      return widget.localUserView!;
    } else if (views.length == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _videoView(views.first),
        ],
      );
    } else if (views.length == 2) {
      return Container(
        child: Column(
          children: <Widget>[
            _expandedVideoRow([views.first]),
            _expandedVideoRow([views[1]]),
          ],
        ),
      );
    } else if (views.length > 2 && views.length % 2 == 0) {
      return Container(
        child: Column(
          children: [
            for (int i = 0; i < views.length; i = i + 2)
              _expandedVideoRow(
                views.sublist(i, i + 2),
              ),
          ],
        ),
      );
    } else if (views.length > 2 && views.length % 2 != 0) {
      return Column(
        children: <Widget>[
          for (int i = 0; i < views.length; i = i + 2)
            i == (views.length - 1)
                ? _expandedVideoRow(views.sublist(i, i + 1))
                : _expandedVideoRow(views.sublist(i, i + 2)),
        ],
      );
    }
    return Container();
  }

  Widget _getLocalViews() {
    return widget.client.sessionController.value.isScreenShared
        ? AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: widget.client.sessionController.value.engine!,
              canvas: const VideoCanvas(
                uid: 0,
                sourceType: VideoSourceType.videoSourceScreen,
              ),
            ),
          )
        : AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: widget.client.sessionController.value.engine!,
              canvas: VideoCanvas(uid: 0, renderMode: widget.renderModeType),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.client.sessionController,
      builder: (context, counter, widgetx) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              _viewGrid(),
              if (!widget.client.sessionController.value.isLocalVideoDisabled &&
                  widget.client.sessionController.value.showLocalCameraView ==
                      true)
                Padding(
                  padding: const EdgeInsets.only(top: 60, right: 20),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () async {
                        await switchCamera(
                          sessionController: widget.client.sessionController,
                        );
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _getLocalViews(),
                            ),
                            Positioned(
                              bottom: 5,
                              child: Container(
                                width: 30,
                                height: 30,
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x8C0EFFFF),
                                      Color(0x8C124DE3),
                                    ],
                                  ),
                                ),
                                child: Assets.icons.switchCamera.svg(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class DisabledVideoStfWidget extends StatefulWidget {
  final Widget? disabledVideoWidget;

  const DisabledVideoStfWidget({Key? key, this.disabledVideoWidget})
      : super(key: key);

  @override
  State<DisabledVideoStfWidget> createState() => _DisabledVideoStfWidgetState();
}

class _DisabledVideoStfWidgetState extends State<DisabledVideoStfWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.disabledVideoWidget!;
  }
}
