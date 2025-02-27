import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../core/utils/all.dart';

class MediaService {
  Future<bool> checkTimeVideo(
    File file, {
    Duration duration = const Duration(minutes: 2),
  }) async {
    try {
      final VideoPlayerController videoPlayerController =
          VideoPlayerController.file(File(file.path));
      await videoPlayerController.initialize();

      if (videoPlayerController.value.duration.compareTo(duration) < 0) {
        await videoPlayerController.dispose();

        return true;
      }
    } catch (e) {
      LogUtil.e(e);
    }

    return false;
  }

  Future<File?> compressVideo(File file) async {
    try {
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.Res1920x1080Quality,
      );

      if (mediaInfo != null) {
        return mediaInfo.file;
      }
    } catch (e) {
      LogUtil.e(e);

      return file;
    }

    return null;
  }

  Future<File?> compressImage(
    File file,
  ) async {
    try {
      final String pathFileInput = file.path;
      final tempPath = await getTemporaryDirectory();

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${tempPath.path}/compress-${pathFileInput.split('/').last.split('.').first}.jpg',
      );

      if (result != null) {
        return File(result.path);
      }
    } catch (e) {
      LogUtil.e(e);

      return file;
    }

    return null;
  }
}
