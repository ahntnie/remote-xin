import 'package:get/get.dart';

import '../../../../../models/base/paginated_list.dart';
import '../../../../../models/comment.dart';
import '../../../../../repositories/newsfeed/newsfeed_repo.dart';
import '../../../../base/all.dart';
import 'comment_input_controller.dart';
import 'comments_controller.dart';

class RootCommentController extends BaseLoadMoreController<Comment> {
  final _newsfeedRepository = Get.find<NewsfeedRepository>();
  final _inputController = Get.find<CommentInputController>();
  final _commentsController = Get.find<CommentsController>();

  @override
  int get pageSize => 3;
  @override
  bool get getListWhenInit => false;
  @override
  bool get autoLoadMore => false;

  final Rx<Comment?> _rootComment = Rx(null);
  Comment get rootComment => _rootComment.value!;

  final RxBool _isExpanded = false.obs;
  bool get isExpanded => _isExpanded.value;

  void injectRootComment(Comment comment) {
    _rootComment.value ??= comment;
  }

  void getReplies() {
    if (rootComment.childrenCount == 0) {
      return;
    }

    _isExpanded.value = true;
    refreshData();
  }

  @override
  Future<PaginatedList<Comment>> fetchPaginatedList({
    required int page,
    required int pageSize,
  }) {
    return _newsfeedRepository.getComments(
      postId: rootComment.postId!,
      parentId: rootComment.id,
      page: page,
      pageSize: pageSize,
    );
  }

  void onLikePressed(Comment comment) {
    if (comment.id == rootComment.id) {
      _onRootCommentLikePressed();
    } else {
      _onChildCommentLikePressed(comment);
    }

    if (comment.isLiked) {
      _newsfeedRepository.unLikeComment(commentId: comment.id);
    } else {
      _newsfeedRepository.likeComment(commentId: comment.id);
    }
  }

  void _onRootCommentLikePressed() {
    _rootComment.value = rootComment.toggleLike();
  }

  void _onChildCommentLikePressed(Comment comment) {
    pagingController.replaceItem(comment, comment.toggleLike());
  }

  void onReplyPressed(Comment comment) {
    _inputController.setReplyToComment(
      comment,
      rootCommentController: this,
    );
  }

  void onChildReplyPosted(Comment comment) {
    if (isExpanded) {
      final lastIndex = pagingController.itemList?.length ?? 0;
      pagingController.insertItemAt(lastIndex, comment);
    } else {
      refreshData();
      _isExpanded.value = true;
    }

    _rootComment.value = rootComment.copyWith(
      childrenCount: rootComment.childrenCount + 1,
    );
  }

  void editComment(Comment comment) {
    _inputController.setEditComment(
      comment,
      rootCommentController: this,
    );
  }

  void onCommentUpdated(Comment updatedComment) {
    if (updatedComment.id == rootComment.id) {
      _rootComment.value = updatedComment;
    } else {
      final comment = pagingController.itemList?.firstWhereOrNull(
        (element) => element.id == updatedComment.id,
      );

      if (comment != null) {
        pagingController.replaceItem(comment, updatedComment);
      }
    }
  }

  void deleteComment(Comment comment) {
    _commentsController.deleteComment(
      comment,
      isRemoveFromList: comment.id == rootComment.id,
    );

    if (comment.id != rootComment.id) {
      _rootComment.value = rootComment.copyWith(
        childrenCount: rootComment.childrenCount - 1,
      );

      final toDeleteCommentId = pagingController.itemList?.indexWhere(
            (element) => element.id == comment.id,
          ) ??
          -1;

      if (toDeleteCommentId != -1) {
        pagingController.removeItemAt(toDeleteCommentId);
      }
    }
  }
}
