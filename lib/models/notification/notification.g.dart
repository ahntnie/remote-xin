// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      contentText: json['content_text'] as String,
      notifiableType: json['notifiable_type'] as String,
      type: json['type'] as String,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
          json['created_at'], const UTCDateTimeConverter().fromJson),
      readAt: _$JsonConverterFromJson<String, DateTime>(
          json['read_at'], const UTCDateTimeConverter().fromJson),
      data: json['data'] == null
          ? null
          : BaseNotificationPayload.fromJson(
              json['data'] as Map<String, dynamic>),
      author: json['author'] == null
          ? null
          : User.fromJson(json['author'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content_text': instance.contentText,
      'notifiable_type': instance.notifiableType,
      'created_at': _$JsonConverterToJson<String, DateTime>(
          instance.createdAt, const UTCDateTimeConverter().toJson),
      'read_at': _$JsonConverterToJson<String, DateTime>(
          instance.readAt, const UTCDateTimeConverter().toJson),
      'type': instance.type,
      'data': instance.data?.toJson(),
      'author': instance.author?.toJson(),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
