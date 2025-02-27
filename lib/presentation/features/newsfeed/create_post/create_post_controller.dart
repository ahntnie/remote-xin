import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../../repositories/all.dart';
import '../../../base/base_controller.dart';
import '../all.dart';

class CreatePostController extends BaseController {
  final postInputResourceController = Get.find<PostInputResourceController>();
  final newsfeedRepository = Get.find<NewsfeedRepository>();
  final PanelController slidingUpPanelController = PanelController();
  FocusNode postContentFocusNode = FocusNode();

  TextEditingController postContentController = TextEditingController();

  bool isFocus = Get.arguments['is_focus'];
  bool isMedia = Get.arguments['is_media'];

  var isHaveText = false.obs;

  @override
  void onInit() {
    postContentFocusNode.addListener(() {
      if (postContentFocusNode.hasFocus) {
        slidingUpPanelController.close();
      }
    });

    if (isFocus) {
      postContentFocusNode.requestFocus();
    }

    if (isMedia) {
      postInputResourceController.pickMedia();
    }

    postContentController.addListener(() {
      final text = postContentController.text.trim();
      isHaveText.value = text.isNotEmpty;
    });

    super.onInit();
  }

  Future<void> uploadPost() async {
    if (postContentController.text.trim().length > 3000) {
      ViewUtil.showToast(
        title: l10n.global__warning_title,
        message: l10n.newsfeed__create_post_limit_content,
      );

      return;
    }

    if (postInputResourceController.pickedListMedia.isEmpty &&
        postContentController.text.trim().isEmpty) {
      ViewUtil.showToast(
        title: l10n.global__warning_title,
        message: l10n.newsfeed__create_post_required,
      );

      return;
    }

    if (postInputResourceController.pickedListMedia.isNotEmpty) {
      await _uploadMedia(postInputResourceController.pickedListMedia).then(
        (attachments) {
          if (attachments.isNotEmpty) {
            _createPost(postContentController.text.trim(), attachments);
          } else {
            ViewUtil.showToast(
              title: l10n.global__error_title,
              message: l10n.newsfeed__create_post_upload_post_failed,
            );
          }
        },
      );
    } else {
      await _createPost(postContentController.text.trim(), []);
    }
  }

  Future<List<int>> _uploadMedia(List<PickedMedia> mediaList) async {
    final List<int> attachments = [];
    await runAction(
      action: () async {
        for (final media in mediaList) {
          final attachment = await newsfeedRepository.createFile(media.file);

          attachments.add(attachment.id);
        }

        return attachments;
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.newsfeed__create_post_upload_post_failed,
        );
      },
    );

    return attachments;
  }

  Future<void> _createPost(String content, List<int> attachments) async {
    await runAction(
      action: () async {
        final Post result = await newsfeedRepository.createPostOrShortVideo(
          type: PostType.post.name,
          content: content,
          attachment: attachments,
        );

        Get.back(result: result);
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.newsfeed__create_post_upload_post_failed,
        );
      },
    );
  }
}
