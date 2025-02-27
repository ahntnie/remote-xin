import 'package:flutter/material.dart';

import '../../../../models/attachment.dart';
import '../../../common_widgets/network_image.dart';
import '../../../common_widgets/video_player.dart';
import '../../../resource/styles/app_colors.dart';
import '../../../resource/styles/gaps.dart';

const double _kDefaultAttachmentSize = 60;
const double _kDefaultAttachmentRadius = 12;

class AttachmentWidget extends StatelessWidget {
  final Attachment attachment;
  final double width;
  final double height;
  final double radius;

  const AttachmentWidget({
    required this.attachment,
    this.width = _kDefaultAttachmentSize,
    this.height = _kDefaultAttachmentSize,
    this.radius = _kDefaultAttachmentRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (attachment.isVideo) {
      child = _buildVideoAttachment(context);
    }

    if (attachment.isImage) {
      child = _buildImageAttachment(context);
    }

    if (child != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      );
    }

    return AppSpacing.emptyBox;
  }

  Widget _buildImageAttachment(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: AspectRatio(
        aspectRatio: (attachment.width != null && attachment.height != null)
            ? attachment.width! / attachment.height!
            : 1.0,
        child: AppNetworkImage(
          attachment.path,
          radius: radius,
          clickToSeeFullImage: true,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              color: AppColors.opacityBackground,
              borderRadius: BorderRadius.circular(radius),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoAttachment(BuildContext context) {
    return AppVideoPlayer(
      attachment.path,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(radius),
      isThumbnailMode: true,
      isClickToShowFullScreen: true,
    );
  }
}
