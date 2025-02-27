import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../../../../../../../../models/message.dart';
import '../../../../../../../common_widgets/all.dart';
import '../../../../../../../resource/styles/app_colors.dart';
import '../../../../../../../resource/styles/gaps.dart';
import '../../../../../../../resource/styles/text_styles.dart';

const _kDefaultMediaWidthPercentage = 0.6;

class PreviewMediaMessageBody extends StatefulWidget {
  final Message message;
  final bool isMine;
  final bool isReaction;

  const PreviewMediaMessageBody({
    required this.isMine,
    required this.message,
    this.isReaction = false,
    super.key,
  });

  @override
  State<PreviewMediaMessageBody> createState() =>
      _PreviewMediaMessageBodyState();
}

class _PreviewMediaMessageBodyState extends State<PreviewMediaMessageBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.message.type != MessageType.text;

  late Message _message;

  @override
  void initState() {
    _message = widget.message;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;

    switch (_message.type) {
      case MessageType.image:
        child = _buildImageMessage();
      case MessageType.video:
        child = _buildVideoMessage();
      case MessageType.audio:
        child = widget.isReaction
            ? Material(
                color: Colors.transparent,
                child: _buildAudioMessage(),
              )
            : _buildAudioMessage();
      default:
        child = AppSpacing.emptyBox;
    }

    return child;
  }

  Widget _buildImageMessage() {
    Widget decorateImage(ImageProvider imageProvider) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: widget.isReaction
            ? Image(
                height: 0.6.sw,
                image: ResizeImage(
                  imageProvider,
                  height: 0.6.sw.toInt().cacheSize(context),
                ),
                fit: BoxFit.cover,
              )
            : Image(
                width: _kDefaultMediaWidthPercentage.sw,
                image: ResizeImage(
                  imageProvider,
                  width: _kDefaultMediaWidthPercentage.sw
                      .toInt()
                      .cacheSize(context),
                ),
              ),
      );
    }

    if (_message.isLocal) {
      return Opacity(
        opacity: 0.5,
        child: decorateImage(
          FileImage(File(_message.content)),
        ),
      );
    }

    return AppNetworkImage(
      _message.content,
      width: _kDefaultMediaWidthPercentage.sw,
      imageBuilder: (context, imageProvider) => decorateImage(imageProvider),
      placeholder: _buildImagePlaceholder(),
      clickToSeeFullImage: true,
    );
  }

  Widget _buildVideoMessage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: AppVideoPlayer(
        _message.content,
        key: ValueKey(_message.content),
        width: _kDefaultMediaWidthPercentage.sw,
        fit: BoxFit.contain,
        isFile: _message.isLocal,
        isThumbnailMode: true,
        isClickToShowFullScreen: true,
      ),
    );
  }

  Widget _buildAudioMessage() {
    return VoiceMessageView(
      backgroundColor: widget.isMine ? AppColors.blue8 : AppColors.grey7,
      activeSliderColor: widget.isMine ? AppColors.blue10 : AppColors.text2,
      circlesColor: widget.isMine ? AppColors.blue10 : AppColors.grey8,
      counterTextStyle: AppTextStyles.s12w400.copyWith(
          color: widget.isMine ? AppColors.pacificBlue : AppColors.text2),
      controller: VoiceController(
        width: 0.34.sw,
        audioSrc: _message.content,
        isFile: _message.isLocal,
        maxDuration: const Duration(seconds: 10),
        onComplete: () {},
        onPause: () {},
        onPlaying: () {},
        onError: (err) {},
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pacificBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      width: _kDefaultMediaWidthPercentage.sw,
      height: _kDefaultMediaWidthPercentage.sw,
      child: const AppDefaultLoading(),
    );
  }
}
