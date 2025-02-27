import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../common_widgets/all.dart';
import '../../../../../resource/styles/app_colors.dart';
import '../../../modal/user_video/user_video.dart';
import '../../../utils/assert_image.dart';
import '../../../utils/colors.dart';
import '../../sound/videos_by_sound.dart';

class MusicDisk extends StatefulWidget {
  final Data? videoData;

  const MusicDisk(this.videoData, {super.key});

  @override
  _MusicDiskState createState() => _MusicDiskState();
}

class _MusicDiskState extends State<MusicDisk>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideosBySoundScreen(widget.videoData)));
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * pi,
            child: child,
          );
        },
        child: Container(
          height: 35,
          width: 35,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: AssetImage(icBgDisk)),
          ),
          padding: const EdgeInsets.all(10),
          child: ClipOval(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.blue10,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Image(
                        image: AssetImage(icMusic),
                        color: ColorRes.white,
                      ),
                    ),
                  ),
                ),
                Center(
                    child: AppCircleAvatar(
                  url: (widget.videoData!.soundImage != null
                      ? widget.videoData!.soundImage!
                      : ''),
                  size: 24,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
