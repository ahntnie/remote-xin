import 'dart:io';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../../core/all.dart';
import '../../../../../models/attachment.dart';
import '../../../../base/base_view.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/styles/gaps.dart';
import '../edit_post_controller.dart';

class ImageGalleryEditPostEdit extends BaseView<EditPostController> {
  const ImageGalleryEditPostEdit({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        titleWidget: const SizedBox(),
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            children: [
              AppSpacing.gapH24,
              ...controller.attachments.map((e) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (e is PickedMedia && e.type == MediaAttachmentType.video)
                      ClipRRect(
                        child: AppVideoPlayer(
                          e.file.path,
                          isFile: true,
                          isThumbnailMode: true,
                          isClickToShowFullScreen: true,
                          width: 1.sw,
                          height: 338.h,
                        ),
                      ),

                    // image
                    if (e is PickedMedia && e.type == MediaAttachmentType.image)
                      SizedBox(
                        width: 1.sw,
                        height: 338.h,
                        child: ClipRRect(
                          child: Image(
                            image: FileImage(
                              File(
                                e.file.path,
                              ),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ).clickable(() {
                        Get.generalDialog(
                          barrierColor: Colors.black87,
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return DismissiblePage(
                              onDismissed: () => Navigator.of(context).pop(),
                              // Start of the optional properties
                              isFullScreen: false,
                              minRadius: 10,
                              maxRadius: 10,
                              dragSensitivity: 1.0,
                              maxTransformValue: .8,
                              direction: DismissiblePageDismissDirection.multi,
                              // onDragStart: () {
                              //   print('onDragStart');
                              // },
                              // onDragUpdate: (details) {
                              //   print(details);
                              // },
                              dismissThresholds: const {
                                DismissiblePageDismissDirection.vertical: .2,
                              },
                              minScale: .8,
                              reverseDuration:
                                  const Duration(milliseconds: 250),
                              // End of the optional properties
                              child: PhotoViewGallery.builder(
                                builder: (BuildContext context, int index) =>
                                    PhotoViewGalleryPageOptions(
                                  imageProvider: FileImage(
                                    File(
                                      e.file.path,
                                    ),
                                  ),
                                  maxScale: 4.0,
                                  minScale: PhotoViewComputedScale.contained,
                                ),
                                itemCount: 1,
                                // loadingBuilder: (context, event) =>
                                //     _imageGalleryLoadingBuilder(event),

                                scrollPhysics: const ClampingScrollPhysics(),
                              ),
                            );
                          },
                        );
                      }),

                    if (e is Attachment && e.isImage)
                      Container(
                        width: 1.sw,
                        constraints: BoxConstraints(maxHeight: 338.h),
                        child: AppNetworkImage(
                          e.path,
                          fit: BoxFit.cover,
                          // width: 1.sw,
                          // height: 338.h,
                          width: (e.width ?? 0) > (ScreenUtil().screenWidth)
                              ? e.width
                              : (ScreenUtil().screenWidth - 40.w),
                          height: (e.height ?? 0) > 398.h ? e.height : 398.h,
                        ).clickable(() {
                          Get.generalDialog(
                            barrierColor: Colors.black87,
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return DismissiblePage(
                                onDismissed: () => Navigator.of(context).pop(),
                                // Start of the optional properties
                                isFullScreen: false,
                                minRadius: 10,
                                maxRadius: 10,
                                dragSensitivity: 1.0,
                                maxTransformValue: .8,
                                direction:
                                    DismissiblePageDismissDirection.multi,
                                // onDragStart: () {
                                //   print('onDragStart');
                                // },
                                // onDragUpdate: (details) {
                                //   print(details);
                                // },
                                dismissThresholds: const {
                                  DismissiblePageDismissDirection.vertical: .2,
                                },
                                minScale: .8,
                                reverseDuration:
                                    const Duration(milliseconds: 250),
                                // End of the optional properties
                                child: PhotoViewGallery.builder(
                                  builder: (BuildContext context, int index) =>
                                      PhotoViewGalleryPageOptions(
                                    imageProvider: NetworkImage(e.path ?? ''),
                                    maxScale: 4.0,
                                    minScale: PhotoViewComputedScale.contained,
                                  ),
                                  itemCount: 1,
                                  // loadingBuilder: (context, event) =>
                                  //     _imageGalleryLoadingBuilder(event),

                                  scrollPhysics: const ClampingScrollPhysics(),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    if (e is Attachment && e.isVideo)
                      ClipRRect(
                        child: AppVideoPlayer(
                          e.path,
                          isThumbnailMode: true,
                          isClickToShowFullScreen: true,
                          width: 1.sw,
                          height: 338.h,
                        ),
                      ),
                    Positioned(
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
                        controller.removeAttachment(e, allowBack: true);
                      }),
                    ),
                  ],
                ).paddingOnly(bottom: 24);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
