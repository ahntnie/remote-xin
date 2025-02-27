import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../../repositories/all.dart';
import '../../../base/all.dart';
import '../all.dart';

class EditPostController extends BaseController {
  final postInputResourceController = Get.find<PostInputResourceController>();
  final _newsfeedRepository = Get.find<NewsfeedRepository>();

  FocusNode postContentFocusNode = FocusNode();
  final PanelController slidingUpPanelController = PanelController();
  TextEditingController postContentController = TextEditingController();

  Post post = Get.arguments['post'] as Post;

  RxList<dynamic> attachments = <dynamic>[].obs;

  var isHaveText = false.obs;

  @override
  void onInit() {
    postContentController.text = post.content ?? '';
    attachments.clear();
    attachments.addAll(post.attachments);
    postContentFocusNode.addListener(() {
      if (postContentFocusNode.hasFocus) {
        slidingUpPanelController.close();
      }
    });

    postContentController.addListener(() {
      final text = postContentController.text.trim();
      isHaveText.value = text.isNotEmpty;
    });

    ever(postInputResourceController.pickedListMedia, (value) {
      if (attachments.length > AppConstants.limitNumberOfMediaFileUpload) {
        postInputResourceController.pickedListMedia.clear();
        ViewUtil.showToast(
          title: l10n.global__warning_title,
          message: l10n.newsfeed__create_post_limit_media,
        );

        return;
      }

      if ((attachments.length + value.length) >
          AppConstants.limitNumberOfMediaFileUpload) {
        postInputResourceController.pickedListMedia.clear();
        ViewUtil.showToast(
          title: l10n.global__warning_title,
          message: l10n.newsfeed__create_post_limit_media,
        );

        return;
      }

      if (value.isEmpty) return;

      attachments.addAll(value);
      postInputResourceController.pickedListMedia.clear();
    });
    super.onInit();
  }

  @override
  void dispose() {
    attachments.clear();
    super.dispose();
  }

  Future<Size> getSizeImage(String url) async {
    final Image image = Image.network(url);
    final Completer<Size> completer = Completer<Size>();
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          final Size size =
              Size(info.image.width.toDouble(), info.image.height.toDouble());
          completer.complete(size);
        },
      ),
    );

    return completer.future;
  }

  void removeAttachment(dynamic attachment, {bool allowBack = false}) {
    attachments.remove(attachment);

    if (attachments.isEmpty && allowBack) {
      Get.back();
    }
  }

  Future<void> updatePost() async {
    if (postContentController.text.trim().length > 3000) {
      ViewUtil.showToast(
        title: l10n.global__warning_title,
        message: l10n.newsfeed__create_post_limit_content,
      );

      return;
    }

    if (attachments.isEmpty && postContentController.text.trim().isEmpty) {
      ViewUtil.showToast(
        title: l10n.global__warning_title,
        message: l10n.newsfeed__create_post_required,
      );

      return;
    }

    await runAction(
      action: () async {
        final List<Attachment> attachmentsFromServer =
            await getListAttachment();

        final List<int> attachmentsIdFromServer = [];

        for (final attachment in attachmentsFromServer) {
          attachmentsIdFromServer.add(attachment.id);
        }

        final Post postUpdated = await updatePostRepository(
          attachments: attachmentsIdFromServer,
          content: postContentController.text.trim(),
          postId: post.id,
        );

        Get.back(result: postUpdated);
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.newsfeed__create_post_upload_post_failed,
        );
      },
    );
  }

  Future<Post> updatePostRepository({
    required List<int> attachments,
    required String content,
    required int postId,
  }) async {
    final Post postUpdated = await _newsfeedRepository.updatePost(
      postId: postId,
      content: content,
      attachments: attachments,
    );

    return postUpdated;
  }

  Future<List<Attachment>> getListAttachment() async {
    final List<Attachment> attachmentsFromServer = [];

    for (final attachment in attachments) {
      if (attachment is PickedMedia) {
        final Attachment result =
            await _newsfeedRepository.createFile(attachment.file);
        attachmentsFromServer.add(result);
      } else if (attachment is Attachment) {
        attachmentsFromServer.add(attachment);
      }
    }

    attachments.clear();

    return attachmentsFromServer;
  }

  void clearPickedMedia() {
    if (postInputResourceController.pickedListMedia.isEmpty) return;

    postInputResourceController.pickedListMedia.clear();
  }
}
