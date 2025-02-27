// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallHistory _$CallHistoryFromJson(Map<String, dynamic> json) => CallHistory(
      userId: json['user_id'] as int,
      status: json['status'] as String,
      duration: json['duration'] as int,
      call: json['call'] == null
          ? null
          : Call.fromJson(json['call'] as Map<String, dynamic>),
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      leftAt: json['left_at'] == null
          ? null
          : DateTime.parse(json['left_at'] as String),
      role: json['role'] as String?,
    );

Map<String, dynamic> _$CallHistoryToJson(CallHistory instance) =>
    <String, dynamic>{
      'call': instance.call?.toJson(),
      'user_id': instance.userId,
      'status': instance.status,
      'duration': instance.duration,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'left_at': instance.leftAt?.toIso8601String(),
      'role': instance.role,
    };
