import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/attachment.dart';
import '../../../../common_widgets/app_icon.dart';
import '../../../../common_widgets/loading.dart';
import '../../../../common_widgets/network_image.dart';
import '../../../../common_widgets/video_player.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../../../resource/styles/gaps.dart';
import '../../../../resource/styles/text_styles.dart';
import '../../../all.dart';
import 'image_gallery_edit_post_edit.dart';

class ImageGalleryEditPost extends StatelessWidget {
  const ImageGalleryEditPost({
    required this.controller,
    super.key,
  });
  final EditPostController controller;

  @override
  Widget build(BuildContext context) {
    final attachments = controller.attachments;
    return Stack(
      children: [
        _buildListImageOrVideo(attachments, context),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            color: Colors.black.withOpacity(0.4),
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Text(
              context.l10n.newsfeed__edit_title,
              style: AppTextStyles.s16w600.copyWith(color: Colors.white),
            ),
          ).clickable(() {
            goToEdit();
          }),
        ),
        Visibility(
          visible: attachments.length == 1,
          child: Positioned(
            top: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: const AppIcon(
                icon: Icons.delete,
                color: Colors.white,
                size: 20,
              ),
            ).clickable(() {
              removeFirstImage();
            }),
          ),
        ),
      ],
    );
  }

  void goToEdit() {
    Get.to(() => const ImageGalleryEditPostEdit());
  }

  void removeFirstImage() {
    final value = controller.attachments.first;
    controller.removeAttachment(value);
  }

  Widget _buildListImageOrVideo(
    List<dynamic> attachments,
    BuildContext context, {
    EdgeInsets margin = const EdgeInsets.symmetric(),
  }) {
    if (attachments.isEmpty) {
      return const SizedBox();
    }

    switch (attachments.length) {
      case 1:
        {
          return Container(
            margin: margin,
            width: 1.sw,
            constraints: BoxConstraints(maxHeight: 460.h),
            child: GestureDetector(
              onTap: () {
                goToEdit();
              },
              child: _buildImageOrVideo(attachments[0], context, 460.h),
            ),
          );
        }

      case 2:
        {
          return Row(
            children: [
              Container(
                margin: margin,
                width: 0.5.sw - 1.5,
                constraints: BoxConstraints(maxHeight: 460.h, minHeight: 460.h),
                child: GestureDetector(
                  onTap: () {
                    goToEdit();
                  },
                  child: _buildImageOrVideo(attachments[0], context, 460.h),
                ),
              ),
              Container(
                color: Colors.white,
                width: 3,
              ),
              Container(
                margin: margin,
                width: 0.5.sw - 1.5,
                constraints: BoxConstraints(maxHeight: 460.h, minHeight: 460.h),
                child: GestureDetector(
                  onTap: () {
                    goToEdit();
                  },
                  child: _buildImageOrVideo(attachments[1], context, 460.h),
                ),
              ),
            ],
          );
        }

      case 3:
        {
          return Column(
            children: [
              Container(
                margin: margin,
                width: 1.sw,
                constraints: BoxConstraints(
                    maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                child: GestureDetector(
                  onTap: () {
                    goToEdit();
                  },
                  child:
                      _buildImageOrVideo(attachments[0], context, 230.h - 1.5),
                ),
              ),
              Container(
                color: Colors.white,
                height: 3,
              ),
              Row(
                children: [
                  Container(
                    margin: margin,
                    width: 0.5.sw - 1.5,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        goToEdit();
                      },
                      child: _buildImageOrVideo(
                          attachments[1], context, 230.h - 1.5),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 3,
                  ),
                  Container(
                    margin: margin,
                    width: 0.5.sw - 1.5,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        goToEdit();
                      },
                      child: _buildImageOrVideo(
                          attachments[2], context, 230.h - 1.5),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

      case 4:
        {
          return Column(
            children: [
              Container(
                margin: margin,
                width: 1.sw,
                constraints: BoxConstraints(
                    maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                child: GestureDetector(
                  onTap: () {
                    goToEdit();
                  },
                  child:
                      _buildImageOrVideo(attachments[0], context, 230.h - 1.5),
                ),
              ),
              Container(
                color: Colors.white,
                height: 3,
              ),
              Row(
                children: [
                  Container(
                    margin: margin,
                    width: (1.sw - 6) / 3,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        goToEdit();
                      },
                      child: _buildImageOrVideo(
                          attachments[1], context, 230.h - 1.5),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 3,
                  ),
                  Container(
                    margin: margin,
                    width: (1.sw - 6) / 3,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        goToEdit();
                      },
                      child: _buildImageOrVideo(
                          attachments[2], context, 230.h - 1.5),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 3,
                  ),
                  Container(
                    margin: margin,
                    width: (1.sw - 6) / 3,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        goToEdit();
                      },
                      child: _buildImageOrVideo(
                          attachments[3], context, 230.h - 1.5),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

      default:
        {
          return Column(
            children: [
              Container(
                margin: margin,
                width: 1.sw,
                constraints: BoxConstraints(
                    maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                child: GestureDetector(
                  onTap: () {
                    goToEdit();
                  },
                  child:
                      _buildImageOrVideo(attachments[0], context, 230.h - 1.5),
                ),
              ),
              Container(
                color: Colors.white,
                height: 3,
              ),
              Row(
                children: [
                  Container(
                    margin: margin,
                    width: (1.sw - 6) / 3,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        goToEdit();
                      },
                      child: _buildImageOrVideo(
                          attachments[1], context, 230.h - 1.5),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 3,
                  ),
                  Container(
                    margin: margin,
                    width: (1.sw - 6) / 3,
                    constraints: BoxConstraints(
                        maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                    child: GestureDetector(
                      onTap: () {
                        goToEdit();
                      },
                      child: _buildImageOrVideo(
                          attachments[2], context, 230.h - 1.5),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 3,
                  ),
                  Stack(
                    children: [
                      Container(
                        margin: margin,
                        width: (1.sw - 6) / 3,
                        constraints: BoxConstraints(
                            maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                        child: GestureDetector(
                          onTap: () {
                            goToEdit();
                          },
                          child: _buildImageOrVideo(
                              attachments[3], context, 230.h - 1.5),
                        ),
                      ),
                      Container(
                        width: (1.sw - 6) / 3,
                        constraints: BoxConstraints(
                            maxHeight: 230.h - 1.5, minHeight: 230.h - 1.5),
                        color: AppColors.text2.withOpacity(0.3),
                        child: Center(
                          child: Text(
                            '+ ${attachments.length - 4}',
                            style: AppTextStyles.s24w600.text1Color,
                          ),
                        ),
                      ).clickable(() {
                        goToEdit();
                      }),
                    ],
                  ),
                ],
              ),
            ],
          );
        }
    }
  }

  Widget _buildImageOrVideo(
      dynamic attachment, BuildContext context, double height) {
    if (attachment is PickedMedia &&
        attachment.type == MediaAttachmentType.video) {
      return _buildVideoPlayer(
        context: context,
        url: attachment.file.path,
        thumbUrl: '',
        height: height,
      );
    }

    if (attachment is PickedMedia &&
        attachment.type == MediaAttachmentType.image) {
      return _buildImage(attachment, context);
    }

    if (attachment is Attachment && attachment.isImage) {
      return _buildImageAttachment(attachment, context);
    }

    if (attachment is Attachment && attachment.isVideo) {
      return _buildVideoPlayerAttachment(
        context: context,
        url: attachment.path,
        thumbUrl: attachment.thumb ?? '',
        isProcessing: attachment.isProcessing ?? false,
      );
    }

    return AppSpacing.emptyBox;
  }

  Widget _buildVideoPlayer({
    required BuildContext context,
    required String url,
    required String thumbUrl,
    required double height,
    bool isProcessing = false,
  }) {
    return Stack(
      children: [
        AppVideoPlayer(
          url,
          isView: true,
          isFile: true,
          isThumbnailMode: true,

          width: 1.sw,
          height: height,
          // radius: Sizes.s20,
          fit: BoxFit.cover,
        ),
        // Positioned.fill(
        //   child: Align(
        //     child: AppIcon(
        //       icon: AppIcons.playAudio,
        //       color: Colors.white,
        //       size: Sizes.s32,
        //     ),
        //   ),
        // ),
        const Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(),
        ).clickable(() {
          goToEdit();
        }),
      ],
    );
  }

  Widget _buildImage(PickedMedia attachment, BuildContext context) {
    return Image(
      image: FileImage(
        File(
          attachment.file.path,
        ),
      ),
      fit: BoxFit.cover,
    );
  }

  Widget _buildVideoPlayerAttachment({
    required BuildContext context,
    required String url,
    required String thumbUrl,
    bool isProcessing = false,
  }) {
    return FutureBuilder(
      future: getSizeImage(thumbUrl),
      builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
        if (snapshot.hasError) {
          return const SizedBox();
        }
        if (snapshot.hasData) {
          return Stack(
            children: [
              AppNetworkImage(
                thumbUrl,
                width: (snapshot.data?.width ?? 0) > (ScreenUtil().screenWidth)
                    ? snapshot.data?.width
                    : (ScreenUtil().screenWidth),
                height: (snapshot.data?.height ?? 0) > 398.h
                    ? snapshot.data?.height
                    : 398.h,
                // radius: Sizes.s20,
                fit: BoxFit.cover,
                sizeLoading: Sizes.s32,
                colorLoading: AppColors.white,
              ),
              Positioned.fill(
                child: Align(
                  child: AppIcon(
                    icon: AppIcons.playAudio,
                    color: Colors.white,
                    size: Sizes.s32,
                  ),
                ),
              ),
            ],
          );
        }

        return const AppDefaultLoading(
          color: AppColors.white,
        );
      },
    );
  }

  Future<Size> getSizeImage(String url) async {
    final Image image = Image.network(url);
    final Completer<Size> completer = Completer<Size>();
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          final Size size =
              Size(info.image.width.toDouble(), info.image.height.toDouble());
          completer.complete(size);
        },
      ),
    );

    return completer.future;
  }

  Widget _buildImageAttachment(Attachment attachment, BuildContext context) {
    return AppNetworkImage(
      attachment.path,
      width: (attachment.width ?? 0) > (ScreenUtil().screenWidth)
          ? attachment.width
          : (ScreenUtil().screenWidth),
      height: (attachment.height ?? 0) > 398.h ? attachment.height : 398.h,
      // radius: Sizes.s20,
      fit: BoxFit.cover,
      sizeLoading: Sizes.s32,
      colorLoading: AppColors.white,
    );
  }
}
