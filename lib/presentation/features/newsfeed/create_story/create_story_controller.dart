import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

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
  RxBool showTextInput = false.obs;
  RxDouble textSize = 22.0.obs;
  RxInt textColor = 0xffffffff.obs;
  Rx<Offset> textPosition = Offset(0.5.sw - 50.w, 0.5.sh - 20.h).obs;
  final _storageRepository = Get.find<StorageRepository>();
  final _newsFeedRepository = Get.find<NewsfeedRepository>();
  RxInt background = 0xff4c5966.obs;
  RxInt currentIndex = 0.obs;
  Rx<VideoPlayerController?> videoController = Rx<VideoPlayerController?>(null);
  Rx<TextEditingController> textController = TextEditingController().obs;
  final postController = Get.find<PostsController>();
  RxString imagePath = ''.obs;
  RxString text = ''.obs;
  PickedMedia? pickedMedia;
  FocusNode focusNode = FocusNode();
  final Rx<GlobalKey> backgroundKey = GlobalKey().obs;
  Future postStory() async {
    final backgroundSize = backgroundKey.value.currentContext?.size;
    if (backgroundSize == null) return;
    final leftRatio = textPosition.value.dx / backgroundSize.width;
    final topRatio = textPosition.value.dy / backgroundSize.height;
    print('Left Ratio: $leftRatio');
    print('Top Ratio: $topRatio');
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
              mediaType: pickedMedia!.type == MediaAttachmentType.image
                  ? 'image'
                  : 'video',
              content: text.value);
          if (code == 'success') {
            afterCreateStorySuccess();
          }
        }
      },
    );
  }
// void postStory() {
//     final screenWidth = Get.width;
//     final screenHeight = Get.height;
//     final leftRatio = textPosition.value.dx / screenWidth;
//     final topRatio = textPosition.value.dy / screenHeight;

//     final story = Story(
//       content: text.value,
//       colorCode: background.value.toRadixString(16).padLeft(8, '0').substring(2),
//       urlMedia: imagePath.value.isNotEmpty ? imagePath.value : null,
//       storyType: imagePath.value.isEmpty ? 'text' : 'image',
//       textPositionX: leftRatio,
//       textPositionY: topRatio,
//       timeEnd: DateTime.now().toIso8601String(),
//       reactions: [],
//     );
//     Get.find<NewsfeedRepository>().createStory(story: story).then((_) {
//       Get.back();
//       Get.find<PostsController>().getListUserStory();
//     });
//   }
  void afterCreateStorySuccess() {
    Get.back();
    ViewUtil.showToast(
      title: l10n.global__success_title,
      message: 'Create successful stories',
    );
    // Get.find<PostsController>().getListUserStory();
    Get.find<ChatDashboardController>().getListUserStory();
  }

  void onPanUpdate(DragUpdateDetails details) {
    final backgroundSize = backgroundKey.value.currentContext?.size;
    if (backgroundSize == null) return;

    // Tính vị trí mới
    final newDx = (textPosition.value.dx + details.delta.dx)
        .clamp(0.0, backgroundSize.width - textSize.value);
    final newDy = (textPosition.value.dy + details.delta.dy)
        .clamp(0.0, (backgroundSize.height * 0.93) - textSize.value);

    textPosition.value = Offset(newDx, newDy);
    print('Text Position - dx: $newDx, dy: $newDy');
    print(
        'Text backgroundSize - dx: ${backgroundSize.height}, dy:  ${backgroundSize.width}');
  }

  // Future<void> getImageFromGallery() async {
  //   await MediaHelper.pickImageFromGallery().then((media) {
  //     if (media != null) {
  //       // attachMedia(media);
  //       pickedMedia = media;
  //       imagePath.value = media.file.path;
  //       // isAvatarLocal = true;
  //     }
  //   }).catchError(
  //     (error) {
  //       // if (error is ValidationException) {
  //       //   ViewUtil.showToast(
  //       //     title: Get.context!.l10n.error__file_is_too_large_title,
  //       //     message: Get.context!.l10n.error__file_is_too_large_message,
  //       //   );
  //       // }
  //     },
  //   );
  // }
  Future<void> getMediaFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? media = await picker.pickMedia();

      if (media != null) {
        // Dispose controller cũ nếu có
        if (videoController.value != null) {
          await videoController.value!.dispose();
          videoController.value = null;
        }

        final MediaAttachmentType mediaType = _determineMediaType(media.path);
        pickedMedia = PickedMedia(
          file: File(media.path),
          type: mediaType,
        );
        imagePath.value = media.path;

        // Nếu là video, khởi tạo VideoPlayerController
        if (mediaType == MediaAttachmentType.video) {
          videoController.value = VideoPlayerController.file(File(media.path))
            ..initialize().then((_) {
              videoController.value!.play(); // Tự động phát (tùy chọn)
              videoController.refresh(); // Cập nhật Rx
            });
        }
        print('Selected media path: ${media.path}');
      } else {
        print('No media selected');
      }
    } catch (error) {
      print('Error picking media: $error');
      ViewUtil.showToast(
        title: l10n.global__error_title,
        message: 'Không thể chọn file: $error',
      );
    }
  }

  @override
  void onClose() {
    videoController.value?.dispose();
    super.onClose();
  }

  MediaAttachmentType _determineMediaType(String path) {
    if (path.endsWith('.jpg') ||
        path.endsWith('.png') ||
        path.endsWith('.jpeg')) {
      return MediaAttachmentType.image;
    } else if (path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.mpeg')) {
      return MediaAttachmentType.video;
    } else {
      return MediaAttachmentType
          .image; // Mặc định là image nếu không xác định được
    }
  }
}
