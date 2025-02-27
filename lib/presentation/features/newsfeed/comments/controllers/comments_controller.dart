import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/base/paginated_list.dart';
import '../../../../../models/comment.dart';
import '../../../../../repositories/newsfeed/newsfeed_repo.dart';
import '../../../../../services/newsfeed_interact_service.dart';
import '../../../../base/all.dart';

class CommentsArguments {
  final int postId;
  final bool isMyPost;
  final bool autoFocus;

  CommentsArguments({
    required this.postId,
    required this.isMyPost,
    this.autoFocus = false,
  });
}

class CommentsController extends BaseLoadMoreController<Comment> {
  final int postIdPostDetail;
  final bool isMyPostPostDetail;
  final bool isPostDetail;

  CommentsController({
    required this.postIdPostDetail,
    required this.isPostDetail,
    required this.isMyPostPostDetail,
  });

  final _newsfeedRepository = Get.find<NewsfeedRepository>();

  late int postId;
  late final bool isMyPost;

  @override
  void onInit() {
    log(isPostDetail.toString());
    if (isPostDetail) {
      postId = postIdPostDetail;
      isMyPost = isMyPostPostDetail;
    } else {
      final arguments = Get.arguments as CommentsArguments;
      postId = arguments.postId;
      isMyPost = arguments.isMyPost;
    }

    super.onInit();
  }

  @override
  Future<PaginatedList<Comment>> fetchPaginatedList({
    required int page,
    required int pageSize,
  }) async {
    return _newsfeedRepository.getComments(
      postId: postId,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<Comment?> postTextComment(
    String textComment, {
    Comment? replyToComment,
  }) async {
    if (textComment.isEmpty) {
      return null;
    }

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final tempComment = Comment(
      id: tempId,
      content: textComment,
      createdAt: DateTime.now(),
      parentId: replyToComment?.id,
      author: currentUser,
    );

    if (replyToComment == null) {
      paginatedList.addItem(tempComment);
    }

    final comment = await _newsfeedRepository.postComment(
      postId: postId,
      content: textComment,
      parentId: replyToComment?.id,
    );
    addCommentCount(comment.id, postId);
    if (replyToComment == null) {
      paginatedList.replaceItem(
        tempComment,
        comment,
      );
    }

    unawaited(refreshData());

    return comment;
  }

  Future<Comment> postMediaComment({
    required PickedMedia media,
    String? textComment,
    Comment? replyToComment,
  }) async {
    late Comment comment;

    await runAction(
      action: () async {
        final attachment = await _newsfeedRepository.createFile(media.file);

        comment = await _newsfeedRepository.postComment(
          postId: postId,
          content: textComment,
          attachmentId: attachment.id,
          parentId: replyToComment?.id,
        );
        addCommentCount(comment.id, postId);
      },
    );

    if (replyToComment == null) {
      paginatedList.addItem(comment);
    }

    unawaited(refreshData());

    return comment;
  }

  Future<void> deleteComment(
    Comment comment, {
    required bool isRemoveFromList,
  }) async {
    await _newsfeedRepository.deleteComment(comment.id);

    if (isRemoveFromList) {
      final toDeleteCommentId = pagingController.itemList?.indexWhere(
            (comment) => comment.id == comment.id,
          ) ??
          -1;

      if (toDeleteCommentId != -1) {
        pagingController.removeItemAt(toDeleteCommentId);
      }
    }
  }

  void addCommentCount(int commentId, int postId) {
    Get.find<NewsfeedInteractService>().commentPost(postId, commentId);
  }
}
