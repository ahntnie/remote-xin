// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseNotificationPayload _$BaseNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    BaseNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
    );

Map<String, dynamic> _$BaseNotificationPayloadToJson(
        BaseNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.lockedChat: 'locked_chat',
  NotificationType.unlockedChat: 'unlocked_chat',
  NotificationType.lockedComment: 'locked_comment',
  NotificationType.unlockComment: 'unlock_comment',
  NotificationType.commentPost: 'comment_post',
  NotificationType.reactComment: 'react_comment',
  NotificationType.lockedPost: 'locked_post',
  NotificationType.unlockedPost: 'unlocked_post',
  NotificationType.reactPost: 'react_post',
  NotificationType.lockedAccount: 'locked_account',
  NotificationType.other: 'other',
};

ChatLockedNotificationPayload _$ChatLockedNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    ChatLockedNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
      conversationId: json['conversation_id'] as String,
    );

Map<String, dynamic> _$ChatLockedNotificationPayloadToJson(
        ChatLockedNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
      'conversation_id': instance.conversationId,
    };

ChatUnlockedNotificationPayload _$ChatUnlockedNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    ChatUnlockedNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
      conversationId: json['conversation_id'] as String,
    );

Map<String, dynamic> _$ChatUnlockedNotificationPayloadToJson(
        ChatUnlockedNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
      'conversation_id': instance.conversationId,
    };

CommentLockedNotificationPayload _$CommentLockedNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    CommentLockedNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
      commentId: json['comment_id'] as String,
    );

Map<String, dynamic> _$CommentLockedNotificationPayloadToJson(
        CommentLockedNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
      'comment_id': instance.commentId,
    };

CommentUnlockedNotificationPayload _$CommentUnlockedNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    CommentUnlockedNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
      commentId: json['comment_id'] as String,
    );

Map<String, dynamic> _$CommentUnlockedNotificationPayloadToJson(
        CommentUnlockedNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
      'comment_id': instance.commentId,
    };

CommentPostNotificationPayload _$CommentPostNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    CommentPostNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
      postId: json['post_id'] as String,
      commentId: json['comment_id'] as String,
    );

Map<String, dynamic> _$CommentPostNotificationPayloadToJson(
        CommentPostNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
      'post_id': instance.postId,
      'comment_id': instance.commentId,
    };

ReactCommentNotificationPayload _$ReactCommentNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    ReactCommentNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
      commentId: json['comment_id'] as String,
      reactorId: json['creator_id'] as String,
      reaction: json['reaction'] as String,
      postId: json['post_id'] as String,
    );

Map<String, dynamic> _$ReactCommentNotificationPayloadToJson(
        ReactCommentNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
      'comment_id': instance.commentId,
      'reaction': instance.reaction,
      'post_id': instance.postId,
      'creator_id': instance.reactorId,
    };

PostLockedNotificationPayload _$PostLockedNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    PostLockedNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
      postId: json['post_id'] as String,
    );

Map<String, dynamic> _$PostLockedNotificationPayloadToJson(
        PostLockedNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
      'post_id': instance.postId,
    };

PostUnlockedNotificationPayload _$PostUnlockedNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    PostUnlockedNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
      postId: json['post_id'] as String,
    );

Map<String, dynamic> _$PostUnlockedNotificationPayloadToJson(
        PostUnlockedNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
      'post_id': instance.postId,
    };

ReactPostNotificationPayload _$ReactPostNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    ReactPostNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
      postId: json['post_id'] as String,
      reactorId: json['creator_id'] as String,
      reaction: json['reaction'] as String,
    );

Map<String, dynamic> _$ReactPostNotificationPayloadToJson(
        ReactPostNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
      'post_id': instance.postId,
      'reaction': instance.reaction,
      'creator_id': instance.reactorId,
    };

LockedAccountNotificationPayload _$LockedAccountNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    LockedAccountNotificationPayload(
      action: $enumDecode(_$NotificationTypeEnumMap, json['action']),
    );

Map<String, dynamic> _$LockedAccountNotificationPayloadToJson(
        LockedAccountNotificationPayload instance) =>
    <String, dynamic>{
      'action': _$NotificationTypeEnumMap[instance.action]!,
    };
