// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as int,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      likeCount: json['like_count'] as int? ?? 0,
      childrenCount: json['children_count'] as int? ?? 0,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      content: json['content'] as String?,
      userReaction:
          $enumDecodeNullable(_$ReactionTypeEnumMap, json['user_reaction']),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      parentId: json['parent_id'] as int?,
      postId: json['post_id'] as int?,
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'like_count': instance.likeCount,
      'children_count': instance.childrenCount,
      'updated_at': instance.updatedAt?.toIso8601String(),
      'content': instance.content,
      'user_reaction': _$ReactionTypeEnumMap[instance.userReaction],
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
      'parent_id': instance.parentId,
      'post_id': instance.postId,
    };

const _$ReactionTypeEnumMap = {
  ReactionType.like: 'like',
};
