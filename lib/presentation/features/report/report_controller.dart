import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/all.dart';
import '../../../core/exceptions/custom/all.dart';
import '../../../models/all.dart';
import '../../../models/enums/type_report_enum.dart';
import '../../../repositories/all.dart';
import '../../../repositories/short-video/short_video_repo.dart';
import '../../base/base_controller.dart';

enum ReportType { post, comment, message, video }

class ReportArgs {
  final ReportType type;
  final dynamic data;

  ReportArgs({
    required this.type,
    required this.data,
  });
}

class ReportController extends BaseController {
  final _newFeedsRepository = Get.find<NewsfeedRepository>();
  final _shortVideoRepository = Get.find<ShortVideoRepository>();
  RxList<CategoryReport> categories = <CategoryReport>[].obs;

  TextEditingController reportController = TextEditingController();
  late ReportType type;
  late int postId;
  late dynamic data;

  @override
  Future<void> onInit() async {
    final args = Get.arguments as ReportArgs;
    type = args.type;
    data = args.data;

    getCategoriesReport();
    super.onInit();
  }

  void getCategoriesReport() {
    runAction(
      action: () async {
        final listCategories = type == ReportType.video
            ? await _shortVideoRepository.getListReasonReportShortVideo()
            : await _newFeedsRepository.getCategoriesReport();
        categories.clear();
        categories.addAll(listCategories);
      },
    );
  }

  void changeSelectedCategory(int index) {
    categories[index].isSelected = !categories[index].isSelected;
    categories.refresh();
  }

  void report() {
    switch (type) {
      case ReportType.post:
        reportPost();
        break;
      case ReportType.comment:
        reportComment();
        break;
      case ReportType.message:
        reportMessage();
        break;
      case ReportType.video:
        reportVideo();
        break;
    }
  }

  Future<void> reportVideo() async {
    final listCategories =
        categories.where((element) => element.isSelected).toList();
    final listIds = listCategories.map((e) => e.id).toList();
    if (listIds.isEmpty && reportController.text.trim().isEmpty) {
      ViewUtil.showToast(
        title: l10n.global__warning_title,
        message: l10n.newsfeed__report_required,
      );

      return;
    }
    Get.back(result: true);
    await _shortVideoRepository.reportShortVideo(
        data, listIds, reportController.text.trim());
  }

  void reportPost() {
    runAction(
      action: () async {
        final listCategories =
            categories.where((element) => element.isSelected).toList();
        final listIds = listCategories.map((e) => e.id).toList();

        if (listIds.isEmpty) {
          ViewUtil.showToast(
            title: l10n.global__warning_title,
            message: l10n.newsfeed__report_required,
          );

          return;
        }

        final String code = await _newFeedsRepository.report(
          data.toString(),
          listIds,
          reportController.text.trim(),
          type: TypeReportEnum.post.value,
        );

        Get.back(result: code);
      },
      onError: (error) {
        if (error is NewsfeedException) {
          if (error.kind == NewsfeedExceptionKind.custom) {
            ViewUtil.showToast(
              title: l10n.global__error_title,
              message: error.exception as String,
            );
          }
        }
      },
    );
  }

  void reportComment() {}

  void reportMessage() {
    runAction(
      action: () async {
        final listCategories =
            categories.where((element) => element.isSelected).toList();
        final listIds = listCategories.map((e) => e.id).toList();

        if (listIds.isEmpty) {
          ViewUtil.showToast(
            title: l10n.global__warning_title,
            message: l10n.newsfeed__report_required,
          );

          return;
        }

        await _newFeedsRepository.report(
          (data as Message).id,
          listIds,
          reportController.text.trim(),
          type: TypeReportEnum.message.value,
        );

        Get.back(result: true);
      },
    );
  }
}
