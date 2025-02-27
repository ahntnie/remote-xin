import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_payload.g.dart';

enum NotificationType {
  @JsonValue('locked_chat')
  lockedChat,
  @JsonValue('unlocked_chat')
  unlockedChat,
  @JsonValue('locked_comment')
  lockedComment,
  @JsonValue('unlock_comment')
  unlockComment,
  @JsonValue('comment_post')
  commentPost,
  @JsonValue('react_comment')
  reactComment,
  @JsonValue('locked_post')
  lockedPost,
  @JsonValue('unlocked_post')
  unlockedPost,
  @JsonValue('react_post')
  reactPost,
  @JsonValue('locked_account')
  lockedAccount,
  @JsonValue('other')
  other;
}

@JsonSerializable()
class BaseNotificationPayload extends Equatable {
  final NotificationType action;

  const BaseNotificationPayload({required this.action});

  factory BaseNotificationPayload.fromJson(Map<String, dynamic> json) {
    final type = $enumDecode(_$NotificationTypeEnumMap, json['action']);
    log(json['action'].toString());
    switch (type) {
      case NotificationType.lockedChat:
        return ChatLockedNotificationPayload.fromJson(json);
      case NotificationType.unlockedChat:
        return ChatUnlockedNotificationPayload.fromJson(json);
      case NotificationType.lockedComment:
        return CommentLockedNotificationPayload.fromJson(json);
      case NotificationType.unlockComment:
        return CommentUnlockedNotificationPayload.fromJson(json);
      case NotificationType.commentPost:
        return CommentPostNotificationPayload.fromJson(json);
      case NotificationType.reactComment:
        return ReactCommentNotificationPayload.fromJson(json);
      case NotificationType.lockedPost:
        return PostLockedNotificationPayload.fromJson(json);
      case NotificationType.unlockedPost:
        return PostUnlockedNotificationPayload.fromJson(json);
      case NotificationType.reactPost:
        return ReactPostNotificationPayload.fromJson(json);
      case NotificationType.lockedAccount:
        return LockedAccountNotificationPayload.fromJson(json);
      default:
        return const BaseNotificationPayload(action: NotificationType.other);
    }
  }

  Map<String, dynamic> toJson() {
    switch (action) {
      case NotificationType.lockedChat:
        return (this as ChatLockedNotificationPayload).toJson();
      case NotificationType.unlockedChat:
        return (this as ChatUnlockedNotificationPayload).toJson();
      case NotificationType.lockedComment:
        return (this as CommentLockedNotificationPayload).toJson();
      case NotificationType.unlockComment:
        return (this as CommentUnlockedNotificationPayload).toJson();
      case NotificationType.commentPost:
        return (this as CommentPostNotificationPayload).toJson();
      case NotificationType.reactComment:
        return (this as ReactCommentNotificationPayload).toJson();
      case NotificationType.lockedPost:
        return (this as PostLockedNotificationPayload).toJson();
      case NotificationType.unlockedPost:
        return (this as PostUnlockedNotificationPayload).toJson();
      case NotificationType.reactPost:
        return (this as ReactPostNotificationPayload).toJson();
      case NotificationType.lockedAccount:
        return (this as LockedAccountNotificationPayload).toJson();
      default:
        return {};
    }
  }

  @override
  List<Object?> get props => [action];
}

@JsonSerializable()
class ChatLockedNotificationPayload extends BaseNotificationPayload {
  final String conversationId;

  const ChatLockedNotificationPayload({
    required super.action,
    required this.conversationId,
  });

  factory ChatLockedNotificationPayload.fromJson(Map<String, dynamic> json) {
    return _$ChatLockedNotificationPayloadFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$ChatLockedNotificationPayloadToJson(this);

  @override
  List<Object?> get props => [action, conversationId];
}

@JsonSerializable()
class ChatUnlockedNotificationPayload extends BaseNotificationPayload {
  final String conversationId;

  const ChatUnlockedNotificationPayload({
    required super.action,
    required this.conversationId,
  });

  factory ChatUnlockedNotificationPayload.fromJson(Map<String, dynamic> json) {
    return _$ChatUnlockedNotificationPayloadFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() =>
      _$ChatUnlockedNotificationPayloadToJson(this);

  @override
  List<Object?> get props => [action, conversationId];
}

@JsonSerializable()
class CommentLockedNotificationPayload extends BaseNotificationPayload {
  final String commentId;

  const CommentLockedNotificationPayload({
    required super.action,
    required this.commentId,
  });

  factory CommentLockedNotificationPayload.fromJson(Map<String, dynamic> json) {
    return _$CommentLockedNotificationPayloadFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() =>
      _$CommentLockedNotificationPayloadToJson(this);

  @override
  List<Object?> get props => [action, commentId];
}

@JsonSerializable()
class CommentUnlockedNotificationPayload extends BaseNotificationPayload {
  final String commentId;

  const CommentUnlockedNotificationPayload({
    required super.action,
    required this.commentId,
  });

  factory CommentUnlockedNotificationPayload.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$CommentUnlockedNotificationPayloadFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() =>
      _$CommentUnlockedNotificationPayloadToJson(this);

  @override
  List<Object?> get props => [action, commentId];
}

@JsonSerializable()
class CommentPostNotificationPayload extends BaseNotificationPayload {
  final String postId;
  final String commentId;

  const CommentPostNotificationPayload({
    required super.action,
    required this.postId,
    required this.commentId,
  });

  factory CommentPostNotificationPayload.fromJson(Map<String, dynamic> json) {
    return _$CommentPostNotificationPayloadFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$CommentPostNotificationPayloadToJson(this);

  @override
  List<Object?> get props => [action, postId, commentId];
}

@JsonSerializable()
class ReactCommentNotificationPayload extends BaseNotificationPayload {
  final String commentId;
  final String reaction;
  final String postId;

  @JsonKey(name: 'creator_id')
  final String reactorId;

  const ReactCommentNotificationPayload({
    required super.action,
    required this.commentId,
    required this.reactorId,
    required this.reaction,
    required this.postId,
  });

  factory ReactCommentNotificationPayload.fromJson(Map<String, dynamic> json) {
    return _$ReactCommentNotificationPayloadFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() =>
      _$ReactCommentNotificationPayloadToJson(this);

  @override
  List<Object?> get props => [action, commentId, reactorId, reaction];
}

@JsonSerializable()
class PostLockedNotificationPayload extends BaseNotificationPayload {
  final String postId;

  const PostLockedNotificationPayload({
    required super.action,
    required this.postId,
  });

  factory PostLockedNotificationPayload.fromJson(Map<String, dynamic> json) {
    return _$PostLockedNotificationPayloadFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$PostLockedNotificationPayloadToJson(this);

  @override
  List<Object?> get props => [action, postId];
}

@JsonSerializable()
class PostUnlockedNotificationPayload extends BaseNotificationPayload {
  final String postId;

  const PostUnlockedNotificationPayload({
    required super.action,
    required this.postId,
  });

  factory PostUnlockedNotificationPayload.fromJson(Map<String, dynamic> json) {
    return _$PostUnlockedNotificationPayloadFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() =>
      _$PostUnlockedNotificationPayloadToJson(this);

  @override
  List<Object?> get props => [action, postId];
}

@JsonSerializable()
class ReactPostNotificationPayload extends BaseNotificationPayload {
  final String postId;
  final String reaction;
  @JsonKey(name: 'creator_id')
  final String reactorId;

  const ReactPostNotificationPayload({
    required super.action,
    required this.postId,
    required this.reactorId,
    required this.reaction,
  });

  factory ReactPostNotificationPayload.fromJson(Map<String, dynamic> json) {
    return _$ReactPostNotificationPayloadFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$ReactPostNotificationPayloadToJson(this);

  @override
  List<Object?> get props => [action, postId, reactorId, reaction];
}

@JsonSerializable()
class LockedAccountNotificationPayload extends BaseNotificationPayload {
  const LockedAccountNotificationPayload({
    required super.action,
  });

  factory LockedAccountNotificationPayload.fromJson(Map<String, dynamic> json) {
    return _$LockedAccountNotificationPayloadFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() =>
      _$LockedAccountNotificationPayloadToJson(this);

  @override
  List<Object?> get props => [action];
}
