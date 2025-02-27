// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_call.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinCall _$JoinCallFromJson(Map<String, dynamic> json) => JoinCall(
      token: json['token'] as String,
      call: Call.fromJson(json['call'] as Map<String, dynamic>),
      appId: json['app_id'] as String,
    );

Map<String, dynamic> _$JoinCallToJson(JoinCall instance) => <String, dynamic>{
      'app_id': instance.appId,
      'token': instance.token,
      'call': instance.call.toJson(),
    };
