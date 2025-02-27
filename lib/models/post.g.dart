// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      userReaction:
          $enumDecodeNullable(_$ReactionTypeEnumMap, json['user_reaction']),
      originalPost: json['original_post'] == null
          ? null
          : Post.fromJson(json['original_post'] as Map<String, dynamic>),
      isShare: json['is_share'] as bool? ?? false,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'type': instance.type,
      'content': instance.content,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
      'share_count': instance.shareCount,
      'created_at': instance.createdAt.toIso8601String(),
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
      'user_reaction': _$ReactionTypeEnumMap[instance.userReaction],
      'author': instance.author.toJson(),
      'original_post': instance.originalPost?.toJson(),
      'is_share': instance.isShare,
    };

const _$ReactionTypeEnumMap = {
  ReactionType.like: 'like',
};
