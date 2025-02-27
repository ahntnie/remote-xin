import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../common_widgets/app_icon.dart';
import '../../../../common_widgets/video_player.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../../../resource/styles/gaps.dart';
import '../../../../resource/styles/text_styles.dart';
import '../../../all.dart';
import 'image_gallery_create_post_edit.dart';

class ImageGalleryCreatePost extends StatelessWidget {
  const ImageGalleryCreatePost({
    required this.controller,
    super.key,
  });
  final CreatePostController controller;

  @override
  Widget build(BuildContext context) {
    final attachments = controller.postInputResourceController.pickedListMedia;
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
    Get.to(() => const ImageGalleryCreatePostEdit());
  }

  void removeFirstImage() {
    final firstMediaFile =
        controller.postInputResourceController.pickedListMedia.first;
    controller.postInputResourceController.removeMedia(firstMediaFile);
  }

  Widget _buildListImageOrVideo(
    List<PickedMedia> attachments,
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
      PickedMedia attachment, BuildContext context, double height) {
    if (attachment.type == MediaAttachmentType.video) {
      return _buildVideoPlayer(
        context: context,
        url: attachment.file.path,
        thumbUrl: '',
        height: height,
      );
    }

    if (attachment.type == MediaAttachmentType.image) {
      return _buildImage(attachment, context);
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
}
