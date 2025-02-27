import 'package:flutter/material.dart';

import '../../core/all.dart';
import '../resource/resource.dart';
import 'app_blurry_container.dart';
import 'app_icon.dart';
import 'video_player.dart';

const double _kDefaultPreviewSize = 60;

class AppMediaPreview extends StatelessWidget {
  final PickedMedia media;
  final void Function() onRemove;
  final double width;
  final double height;

  const AppMediaPreview({
    required this.media,
    required this.onRemove,
    this.width = _kDefaultPreviewSize,
    this.height = _kDefaultPreviewSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (media.type == MediaAttachmentType.audio) {
      return AppSpacing.emptyBox;
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: AppBlurryContainer(
            color: AppColors.blue8,
            padding: EdgeInsets.zero,
            borderRadius: 6,
            child: _buildPreview(context),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: AppIcon(
            backgroundColor: AppColors.pacificBlue,
            isCircle: true,
            size: Sizes.s12,
            icon: AppIcons.close,
            color: AppColors.text1,
            onTap: onRemove,
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    switch (media.type) {
      case MediaAttachmentType.image:
        return _buildImagePreview();
      case MediaAttachmentType.video:
        return _buildVideoPreview();
      case MediaAttachmentType.document:
        return _buildDocumentPreview();
      case MediaAttachmentType.audio:
        return AppSpacing.emptyBox;
    }
  }

  Widget _buildImagePreview() {
    return Image(
      width: width,
      height: height,
      image: FileImage(media.file),
      fit: BoxFit.cover,
    ).clickable(() {
      ViewUtil.showImageDialog(
        imageFile: media.file,
      );
    });
  }

  Widget _buildVideoPreview() {
    return AppVideoPlayer(
      media.file.path,
      width: width,
      height: height,
      fit: BoxFit.fitWidth,
      isFile: true,
      isThumbnailMode: true,
      playButtonSize: Sizes.s16,
      isClickToShowFullScreen: true,
    );
  }

  Widget _buildDocumentPreview() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.insert_drive_file,
            color: AppColors.pacificBlue,
          ),
          AppSpacing.gapW4,
          Flexible(
            child: Text(
              media.file.path.split('/').last,
              style: AppTextStyles.s14w400.toColor(AppColors.pacificBlue),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
