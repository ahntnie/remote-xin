import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/all.dart';
import '../resource/styles/styles.dart';
import 'app_icon.dart';
import 'loading.dart';

class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.isFile = false,
    this.autoPlay = false,
    this.loadingColor,
    this.onTap,
    this.onPlayingStateCallback,
    this.fit,
    this.isThumbnailMode = false,
    this.isClickToShowFullScreen = false,
    this.onFullScreenLongPress,
    this.playButtonSize = Sizes.s32,
    this.isView = false,
  });

  final String url;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final bool isFile;
  final bool autoPlay;
  final Color? loadingColor;
  final VoidCallback? onTap;
  final void Function(bool isPlaying)? onPlayingStateCallback;
  final BoxFit? fit;
  final bool isThumbnailMode;
  final bool isClickToShowFullScreen;
  final VoidCallback? onFullScreenLongPress;
  final double playButtonSize;
  final bool isView;

  @override
  State<AppVideoPlayer> createState() => AppVideoPlayerState();
}

class AppVideoPlayerState extends State<AppVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  final ValueNotifier<bool> _isPlayingNotifier = ValueNotifier(false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _videoPlayerController = widget.isFile
        ? VideoPlayerController.file(File(widget.url))
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));

    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: widget.autoPlay,
      looping: true,
      showControls: !widget.isThumbnailMode,
      showControlsOnInitialize: !widget.isThumbnailMode,
      showOptions: !widget.isThumbnailMode,
      allowFullScreen: false,
    );

    _videoPlayerController!.addListener(() {
      if (_videoPlayerController!.value.isPlaying != _isPlayingNotifier.value) {
        _isPlayingNotifier.value = _videoPlayerController!.value.isPlaying;
        widget.onPlayingStateCallback
            ?.call(_videoPlayerController!.value.isPlaying);
      }
    });

    if (widget.autoPlay) {
      play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    pause();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _isPlayingNotifier.dispose();
    super.dispose();
  }

  void play() {
    _videoPlayerController?.play();
  }

  void pause() {
    _videoPlayerController?.pause();
  }

  void _onTap() {
    if (widget.isThumbnailMode) {
      if (!widget.isClickToShowFullScreen) {
        return;
      }

      return ViewUtil.showVideoDialog(
        widget.url,
        isFile: widget.isFile,
        onLongPress: widget.onFullScreenLongPress,
      );
    } else if (_videoPlayerController!.value.isPlaying) {
      pause();
    }

    widget.onTap?.call();
  }

  void _onPlayButtonPressed() {
    if (_videoPlayerController!.value.isInitialized &&
        _videoPlayerController!.value.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final child = _videoPlayerController!.value.isInitialized
        ? _buildBody()
        : _buildLoading();

    // if (widget.isThumbnailMode) {
    //   return child;
    // }

    if (widget.isView) {
      return Stack(
        alignment: Alignment.center,
        children: [
          child,
          if (_videoPlayerController!.value.isInitialized) _buildPlayButton(),
        ],
      );
    }

    return VisibilityDetector(
      key: Key(widget.url),
      onVisibilityChanged: (info) {
        if (_videoPlayerController!.value.isPlaying &&
            info.visibleFraction == 0) {
          pause();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          if (_videoPlayerController!.value.isInitialized) _buildPlayButton(),
        ],
      ),
    ).clickable(_onTap);
  }

  SizedBox _buildLoading() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AppDefaultLoading(
        color: widget.loadingColor,
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: widget.borderRadius,
      ),
      child: FittedBox(
        fit: widget.fit ?? BoxFit.contain,
        child: SizedBox(
          width: widget.width ?? _videoPlayerController!.value.size.width,
          height: widget.height ??
              (widget.width != null
                  ? widget.width! / _videoPlayerController!.value.aspectRatio
                  : _videoPlayerController!.value.size.height),
          child: Chewie(
            controller: _chewieController!,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPlayingNotifier,
      builder: (_, isPlaying, __) {
        final child = AnimatedOpacity(
          opacity: isPlaying ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: AppIcon(
            icon: AppIcons.playAudio,
            color: Colors.white,
            size: widget.playButtonSize,
          ),
        );

        if (widget.isThumbnailMode) {
          return child;
        }

        return child.clickable(_onPlayButtonPressed);
      },
    );
  }
}
