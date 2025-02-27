// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Call _$CallFromJson(Map<String, dynamic> json) => Call(
      id: json['id'] as String,
      chatChannelId: json['chat_channel_id'] as String,
      isGroup: json['is_group'] as bool?,
      isVideo: json['is_video'] as bool?,
      isTranslate: json['is_translate'] as bool?,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
          json['created_at'], const UTCDateTimeConverter().fromJson),
      startedAt: _$JsonConverterFromJson<String, DateTime>(
          json['started_at'], const UTCDateTimeConverter().fromJson),
      canceledAt: _$JsonConverterFromJson<String, DateTime>(
          json['canceled_at'], const UTCDateTimeConverter().fromJson),
      endedAt: _$JsonConverterFromJson<String, DateTime>(
          json['ended_at'], const UTCDateTimeConverter().fromJson),
      duration: json['duration'] as int?,
      callers: (json['callers'] as List<dynamic>?)
              ?.map((e) => Callers.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      receivers: (json['receivers'] as List<dynamic>?)
              ?.map((e) => Receivers.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      callHistories: (json['participants'] as List<dynamic>?)
          ?.map((e) => CallHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      conversation: json['conversation'] == null
          ? null
          : Conversation.fromJson(json['conversation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CallToJson(Call instance) => <String, dynamic>{
      'id': instance.id,
      'chat_channel_id': instance.chatChannelId,
      'is_group': instance.isGroup,
      'is_video': instance.isVideo,
      'is_translate': instance.isTranslate,
      'created_at': _$JsonConverterToJson<String, DateTime>(
          instance.createdAt, const UTCDateTimeConverter().toJson),
      'started_at': _$JsonConverterToJson<String, DateTime>(
          instance.startedAt, const UTCDateTimeConverter().toJson),
      'canceled_at': _$JsonConverterToJson<String, DateTime>(
          instance.canceledAt, const UTCDateTimeConverter().toJson),
      'ended_at': _$JsonConverterToJson<String, DateTime>(
          instance.endedAt, const UTCDateTimeConverter().toJson),
      'duration': instance.duration,
      'callers': instance.callers.map((e) => e.toJson()).toList(),
      'receivers': instance.receivers.map((e) => e.toJson()).toList(),
      'participants': instance.callHistories?.map((e) => e.toJson()).toList(),
      'conversation': instance.conversation?.toJson(),
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
