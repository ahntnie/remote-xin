import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/comment.dart';
import '../../../../../repositories/newsfeed/newsfeed_repo.dart';
import '../../../../base/all.dart';
import 'comments_controller.dart';
import 'root_comment_controller.dart';

class CommentInputController extends BaseController {
  final int postIdPostDetail;
  final bool isMyPostPostDetail;
  final bool isPostDetail;
  final bool isFocus;

  CommentInputController({
    required this.postIdPostDetail,
    required this.isPostDetail,
    required this.isMyPostPostDetail,
    this.isFocus = false,
  });

  final _newsfeedRepository = Get.find<NewsfeedRepository>();
  final _commentsController = Get.find<CommentsController>();

  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  final _textComment = ''.obs;
  String get textComment => _textComment.value;

  RootCommentController? rootCommentController;

  final Rx<Comment?> _replyToComment = Rx(null);
  Comment? get replyToComment => _replyToComment.value;

  final Rx<Comment?> _toEditComment = Rx(null);
  Comment? get toEditComment => _toEditComment.value;

  final Rx<PickedMedia?> _pickedMedia = Rx(null);
  PickedMedia? get pickedMedia => _pickedMedia.value;

  @override
  void onInit() {
    if (isFocus) {
      focusNode.requestFocus();
    }
    try {
      if (isMyPostPostDetail) {
        final arguments = Get.arguments as CommentsArguments;

        if (arguments.autoFocus) {
          focusNode.requestFocus();
        }
      }
    } catch (e) {
      LogUtil.e(e);
    }

    super.onInit();
  }

  Future<void> postComment() async {
    if (textComment.isEmpty && pickedMedia == null) {
      return;
    }

    if (toEditComment != null) {
      await _editComment();
    } else {
      Comment? comment;

      if (pickedMedia != null) {
        comment = await _commentsController.postMediaComment(
          media: pickedMedia!,
          textComment: textComment,
          replyToComment: replyToComment,
        );
      } else if (textComment.isNotEmpty) {
        comment = await _commentsController.postTextComment(
          textComment,
          replyToComment: replyToComment,
        );
      }

      if (comment != null && replyToComment != null) {
        rootCommentController?.onChildReplyPosted(comment);
      }
    }

    _onCommentPosted();
  }

  Future<void> _editComment() async {
    final updatedComment =
        await _newsfeedRepository.editComment(toEditComment!.id, textComment);
    rootCommentController?.onCommentUpdated(updatedComment);
  }

  void _onCommentPosted() {
    textEditingController.clear();
    _textComment.value = '';
    _replyToComment.value = null;
    _toEditComment.value = null;
    rootCommentController = null;
    _pickedMedia.value = null;
    ViewUtil.hideKeyboard(Get.context!);
  }

  void onChanged(String value) {
    _textComment.value = value;
  }

  void setReplyToComment(
    Comment? comment, {
    RootCommentController? rootCommentController,
  }) {
    _replyToComment.value = comment;

    if (comment != null) {
      this.rootCommentController = rootCommentController;
      focusNode.requestFocus();
    } else {
      rootCommentController = null;
      ViewUtil.hideKeyboard(Get.context!);
    }
  }

  void setEditComment(
    Comment? comment, {
    RootCommentController? rootCommentController,
  }) {
    _toEditComment.value = comment;

    if (comment != null) {
      this.rootCommentController = rootCommentController;
      textEditingController.text = comment.comment;
      _textComment.value = comment.comment;
      focusNode.requestFocus();
    } else {
      rootCommentController = null;
      ViewUtil.hideKeyboard(Get.context!);
    }
  }

  void attachMedia(PickedMedia? media) {
    _pickedMedia.value = media;
  }

  void removeMedia() {
    _pickedMedia.value = null;
  }
}
