import 'package:freezed_annotation/freezed_annotation.dart';

import 'attachment.dart';
import 'reaction_type_enum.dart';
import 'user.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const Comment._();

  const factory Comment({
    required int id,
    required User author,
    required DateTime createdAt,
    @Default(0) int likeCount,
    @Default(0) int childrenCount,
    DateTime? updatedAt,
    String? content,
    ReactionType? userReaction,
    @Default([]) List<Attachment> attachments,
    int? parentId,
    // This field is calculated on the client side whatever gets from the server
    int? postId,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  factory Comment.fromJsonList(List<dynamic> json) {
    return Comment.fromJson(json.first as Map<String, dynamic>);
  }

  bool get isLiked => userReaction == ReactionType.like;

  String get authorName => author.displayName;

  String get comment => content ?? 'NO_CONTENT';

  Attachment? get firstAttachment =>
      attachments.isNotEmpty ? attachments.first : null;

  Comment toggleLike() {
    return copyWith(
      likeCount: isLiked ? likeCount - 1 : likeCount + 1,
      userReaction: isLiked ? null : ReactionType.like,
    );
  }

  bool isMine(int userId) {
    return author.id == userId;
  }
}
