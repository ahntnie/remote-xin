import 'package:json_annotation/json_annotation.dart';

import 'all.dart';

part 'post.g.dart';

@JsonSerializable(explicitToJson: true)
class Post {
  final int id;
  final String uuid;
  final String type;
  final String? content;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final List<Attachment> attachments;
  final ReactionType? userReaction;
  final User author;
  final Post? originalPost;
  final bool isShare;

  Post({
    required this.id,
    required this.uuid,
    required this.type,
    required this.createdAt,
    required this.author,
    this.content,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.attachments = const [],
    this.userReaction,
    this.originalPost,
    this.isShare = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final post = _$PostFromJson(json);

    return post;
  }

  static List<Post> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Post copyWith({
    int? likeCount,
    ReactionType? userReaction,
    int? commentCount,
  }) {
    return Post(
      id: id,
      uuid: uuid,
      type: type,
      content: content,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount,
      attachments: attachments,
      userReaction: userReaction,
      author: author,
      originalPost: originalPost,
      isShare: isShare,
    );
  }

  Map<String, dynamic> toJson() => _$PostToJson(this);

  bool isMine(int userId) {
    return author.id == userId;
  }
}
