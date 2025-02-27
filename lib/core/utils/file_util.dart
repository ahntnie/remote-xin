import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/attachment.dart';

class FileUtil {
  /// If set, we want to save all files into a specific folder
  static String? defaultDir;

  static bool isExist(String filePath) {
    return File(filePath).existsSync();
  }

  static bool isFolder(String filePath) {
    return FileSystemEntity.typeSync(filePath) ==
        FileSystemEntityType.directory;
  }

  static Future<bool> removeFile(String filePath) async {
    try {
      await File(filePath).delete(recursive: true);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> saveNetworkAttachment(
    Attachment attachment,
  ) async {
    try {
      return attachment.isImage
          ? saveNetworkImage(attachment.path)
          : saveNetworkFile(attachment.path);
    } catch (e) {
      debugPrint('Error saving file: $e');
    }
  }

  static Future<void> saveNetworkImage(String url) async {
    try {
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
      );

      debugPrint('Result: $result');
    } catch (e) {
      debugPrint('Error saving file: $e');
    }
  }

  static Future<void> saveNetworkFile(String url) async {
    try {
      final appDocDir = await getTemporaryDirectory();
      final savePath = '${appDocDir.path}/${url.split('/').last}';
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (count, total) {
          debugPrint('${(count / total * 100).toStringAsFixed(0)}%');
        },
      );

      return ImageGallerySaver.saveFile(savePath);
    } catch (e) {
      debugPrint('Error saving file: $e');
    }
  }
}
