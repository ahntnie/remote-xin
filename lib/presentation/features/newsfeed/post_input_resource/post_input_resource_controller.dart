import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/all.dart';
import '../../../../services/all.dart';
import '../../../base/all.dart';

class PostInputResourceController extends BaseController {
  RxList<PickedMedia> pickedListMedia = <PickedMedia>[].obs;

  RxBool isLoadingResource = false.obs;

  @override
  void onInit() {
    pickedListMedia.clear();
    super.onInit();
  }

  @override
  void onClose() {
    pickedListMedia.clear();
    super.onClose();
  }

  Future<void> _requestPermissionCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      return;
    } else if (status.isPermanentlyDenied) {
      _openSetting();
    }
  }

  void _openSetting() {
    final context = Get.context;
    if (context == null) {
      return;
    }

    ViewUtil.showAppCupertinoAlertDialog(
      title: context.l10n.notification__title,
      message: context.l10n.permission__camera_photo,
      negativeText: context.l10n.button__cancel,
      positiveText: context.l10n.button__confirm,
      onPositivePressed: () async {
        await openAppSettings();
      },
    );
  }

  Future<void> takePhotoFromCamera() async {
    try {
      ViewUtil.hideKeyboard(Get.context!);

      if (pickedListMedia.length >= AppConstants.limitNumberOfMediaFileUpload) {
        ViewUtil.showToast(
          title: l10n.global__warning_title,
          message: l10n.newsfeed__create_post_limit_media,
        );

        return;
      }
      isLoadingResource.value = true;
      update();

      final PickedMedia? takePhoto = await MediaHelper.takeImageFromCamera();
      if (takePhoto != null) {
        final File? fileCompress =
            await MediaService().compressImage(takePhoto.file);

        if (fileCompress != null) {
          logInfo('fileCompress Image: ${await fileCompress.length()}');
          pickedListMedia.add(PickedMedia(
            file: fileCompress,
            type: MediaAttachmentType.image,
          ));
        } else {
          pickedListMedia.add(takePhoto);
        }
      }
    } catch (e) {
      logError(e);
      if (e is PlatformException) {
        if (e.code == 'camera_access_denied') {
          await _requestPermissionCamera();
        }
      } else {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.newsfeed__error_take_photo,
        );
      }
    } finally {
      isLoadingResource.value = false;
      update();
    }
  }

  Future<void> _requestPermissionPhotos() async {
    final status = await Permission.photos.request();
    if (status.isDenied) {
      return;
    } else if (status.isPermanentlyDenied) {
      _openSetting();
    }
  }

  Future<void> pickMedia() async {
    try {
      ViewUtil.hideKeyboard(Get.context!);

      if (pickedListMedia.length >= AppConstants.limitNumberOfMediaFileUpload) {
        ViewUtil.showToast(
          title: l10n.global__warning_title,
          message: l10n.newsfeed__create_post_limit_media,
        );

        return;
      }

      isLoadingResource.value = true;
      update();

      final List<PickedMedia> pickedMedia =
          await MediaHelper.pickMultipleMediaFromGallery();

      if (pickedListMedia.length + pickedMedia.length >
          AppConstants.limitNumberOfMediaFileUpload) {
        ViewUtil.showToast(
          title: l10n.global__warning_title,
          message: l10n.newsfeed__create_post_limit_media,
        );

        return;
      }

      pickedListMedia.addAll(pickedMedia);
    } on Exception catch (e) {
      logError(e);

      if (e is PlatformException) {
        if (e.code == 'photo_access_denied') {
          await _requestPermissionPhotos();
        }
      } else {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      isLoadingResource.value = false;
      update();
    }
  }

  Future<void> pickVideoFromCamera() async {
    try {
      if (pickedListMedia.length >= AppConstants.limitNumberOfMediaFileUpload) {
        ViewUtil.showToast(
          title: l10n.global__warning_title,
          message: l10n.newsfeed__create_post_limit_media,
        );

        return;
      }

      isLoadingResource.value = true;
      update();

      final PickedMedia? pickedVideo = await MediaHelper.pickVideoFromCamera(
        maxDuration: const Duration(minutes: 2),
      );
      if (pickedVideo != null) {
        final bool isTimeValid = await MediaService().checkTimeVideo(
          pickedVideo.file,
        );

        if (isTimeValid) {
          final File? fileCompress =
              await MediaService().compressVideo(pickedVideo.file);
          if (fileCompress != null) {
            final PickedMedia videoCompress = PickedMedia(
              file: fileCompress,
              type: MediaAttachmentType.video,
            );

            pickedListMedia.add(videoCompress);
          } else {
            pickedListMedia.add(pickedVideo);
          }
        } else {
          ViewUtil.showToast(
            title: l10n.global__warning_title,
            message: l10n.newsfeed__video_duration_required,
          );
        }
      }
    } catch (e) {
      logError(e);
      ViewUtil.showToast(
        title: l10n.global__error_title,
        message: 'Picked video is error',
      );
    } finally {
      isLoadingResource.value = false;
      update();
    }
  }

  void removeMedia(PickedMedia media, {bool allowBack = false}) {
    if (media.file.existsSync()) {
      media.file.delete();
    }

    pickedListMedia.remove(media);

    if (pickedListMedia.isEmpty && allowBack) {
      Get.back();
    }

    update();
  }
}
