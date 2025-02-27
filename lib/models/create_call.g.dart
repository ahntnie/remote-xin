// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_call.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCall _$CreateCallFromJson(Map<String, dynamic> json) => CreateCall(
      token: json['token'] as String,
      appId: json['app_id'] as String,
      callId: json['call_id'] as String,
    );

Map<String, dynamic> _$CreateCallToJson(CreateCall instance) =>
    <String, dynamic>{
      'app_id': instance.appId,
      'token': instance.token,
      'call_id': instance.callId,
    };
