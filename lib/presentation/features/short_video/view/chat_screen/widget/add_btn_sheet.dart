import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../api/api_service.dart';
import '../../../custom_view/common_ui.dart';
import '../../../languages/languages_keys.dart';
import '../../../utils/colors.dart';
import '../../../utils/const_res.dart';
import '../../../utils/firebase_res.dart';
import '../../../utils/font_res.dart';
import '../../../utils/my_loading/my_loading.dart';
import 'image_video_msg_screen.dart';

class AddBtnSheet extends StatelessWidget {
  final Function(
      {String? msgType,
      String? imagePath,
      String? videoPath,
      String? msg}) fireBaseMsg;

  AddBtnSheet({required this.fireBaseMsg, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) {
        return Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  color: myLoading.isDark
                      ? ColorRes.colorPrimary
                      : ColorRes.greyShade100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 8),
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 10),
                    child: Text(
                      LKey.whichItemWouldYouLikeToSelectNSelectAItem.tr,
                      style: const TextStyle(
                          color: ColorRes.colorTextLight,
                          fontSize: 17,
                          fontFamily: FontRes.fNSfUiSemiBold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTilesCustom(
                    onTap: (p0) {
                      if (p0 == 0) {
                        onImageClick(context);
                      } else if (p0 == 1) {
                        onVideoClick(context);
                      } else if (p0 == 2) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> onImageClick(BuildContext context) async {
    File? images;
    // Pick an image
    CommonUI.showLoader(context);
    final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxHeight: maxHeight,
        maxWidth: maxWidth);
    Navigator.pop(context);
    if (image == null || image.path.isEmpty) return;
    images = File(image.path);
    log(images.path);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ImageVideoMsgScreen(
          image: images?.path,
          onIVSubmitClick: ({text}) {
            CommonUI.showLoader(context);
            ApiService().filePath(filePath: images).then((value) {
              log('==================== ${value.path}');
              fireBaseMsg(
                  msgType: FirebaseRes.image,
                  imagePath: value.path,
                  videoPath: null,
                  msg: text);
            }).then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            });
          },
        );
      },
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> onVideoClick(BuildContext context) async {
    File? videos;
    String? imageUrl;
    String? videoUrl;
    CommonUI.showLoader(context);
    final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(seconds: 30));
    Navigator.pop(context);
    if (video == null || video.path.isEmpty) return;

    /// calculating file size
    videos = File(video.path);
    final int sizeInBytes = videos.lengthSync();
    final double sizeInMb = sizeInBytes / (1024 * 1024);

    if (sizeInMb <= 15) {
      await VideoThumbnail.thumbnailFile(video: videos.path).then(
        (value) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return ImageVideoMsgScreen(
                image: value,
                onIVSubmitClick: ({text}) {
                  CommonUI.showLoader(context);
                  ApiService()
                      .filePath(filePath: File(value ?? ''))
                      .then((value) {
                    imageUrl = value.path;
                  }).then(
                    (value) {
                      ApiService().filePath(filePath: videos).then((value) {
                        videoUrl = value.path;
                      }).then(
                        (value) {
                          fireBaseMsg(
                              videoPath: videoUrl,
                              msgType: FirebaseRes.video,
                              imagePath: imageUrl,
                              msg: text);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    }
  }
}

class ListTilesCustom extends StatelessWidget {
  final Function(int) onTap;

  const ListTilesCustom({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: 3,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => onTap(index),
          child: Column(
            children: [
              const Divider(color: Colors.grey, indent: 15, endIndent: 15),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  index == 0
                      ? LKey.images.tr
                      : index == 1
                          ? LKey.videos.tr
                          : LKey.close.tr,
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: FontRes.fNSfUiRegular,
                      color: index == 2 ? Colors.red : null),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
