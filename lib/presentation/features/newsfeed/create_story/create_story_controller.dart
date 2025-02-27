import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../repositories/all.dart';
import '../../../base/all.dart';
import '../../all.dart';

class CreateStoryController extends BaseController {
  List<int> colors = [
    0xff4c5966,
    0xffeee5e6,
    0xffccccff,
    0xff737300,
    0xff0000ff,
    0xffff0000,
    0xffffff00,
    0xffff3232,
    0xff20b2aa,
    0xffffb6c1,
    0xffff7373,
    0xff40e0d0,
    0xff008080,
    0xffffc0cb,
    0xffe54385,
    0xffff9302,
    0xff7bc043,
    0xff4c2d37,
    0xffff4d9b,
    0xffed4e8f,
    0xfffc417c,
    0xffffffff,
    0xff000000,
    0xfff9f3ed,
    0xffed8dfd,
    0xff8850be,
    0xfffa3c01,
    0xfff4ad82,
    0xffff8456,
    0xffebc8ff,
    0xff5dd4a2,
    0xfff7b731,
    0xff87624b,
    0xff99b2cc,
    0xff973544,
    0xff1a7277,
    0xff37006c,
    0xffce430b,
    0xff99b2cc,
    0xff8a2be2,
    0xff66cccc,
    0xffff00ff,
  ];
  final _storageRepository = Get.find<StorageRepository>();
  final _newsFeedRepository = Get.find<NewsfeedRepository>();
  RxInt background = 0xff4c5966.obs;
  RxInt currentIndex = 0.obs;
  Rx<TextEditingController> textController = TextEditingController().obs;
  final postController = Get.find<PostsController>();
  RxString imagePath = ''.obs;
  RxString text = ''.obs;
  PickedMedia? pickedMedia;
  FocusNode focusNode = FocusNode();

  Future postStory() async {
    await runAction(
      action: () async {
        String code = '';
        if (imagePath.value == '') {
          code = await _newsFeedRepository.postStory(
              colorCode:
                  colors[currentIndex.value].toRadixString(16).substring(2),
              content: text.value,
              storyType: 'text');
          if (code == 'success') {
            log(code);
            afterCreateStorySuccess();
          }
        } else {
          final url = await _storageRepository.uploadUserAvatar(
              file: pickedMedia!.file, currentUserId: currentUser.id);
          code = await _newsFeedRepository.postStory(
              storyType: 'media',
              mediaType: 'image',
              urlMedia: url,
              content: text.value);
          if (code == 'success') {
            afterCreateStorySuccess();
          }
        }
      },
    );
  }

  void afterCreateStorySuccess() {
    Get.back();
    ViewUtil.showToast(
      title: l10n.global__success_title,
      message: 'Create successful stories',
    );
    // Get.find<PostsController>().getListUserStory();
    Get.find<ChatDashboardController>().getListUserStory();
  }

  Future<void> getImageFromGallery() async {
    await MediaHelper.pickImageFromGallery().then((media) {
      if (media != null) {
        // attachMedia(media);
        pickedMedia = media;
        imagePath.value = media.file.path;
        // isAvatarLocal = true;
      }
    }).catchError(
      (error) {
        // if (error is ValidationException) {
        //   ViewUtil.showToast(
        //     title: Get.context!.l10n.error__file_is_too_large_title,
        //     message: Get.context!.l10n.error__file_is_too_large_message,
        //   );
        // }
      },
    );
  }
}
