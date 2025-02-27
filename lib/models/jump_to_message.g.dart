// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jump_to_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JumpToMessage _$JumpToMessageFromJson(Map<String, dynamic> json) =>
    JumpToMessage(
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      limit: json['limit'] as int?,
      skip: json['skip'] as int?,
      pageNumber: json['pageNumber'] as int?,
    );

Map<String, dynamic> _$JumpToMessageToJson(JumpToMessage instance) =>
    <String, dynamic>{
      'messages': instance.messages?.map((e) => e.toJson()).toList(),
      'limit': instance.limit,
      'skip': instance.skip,
      'pageNumber': instance.pageNumber,
    };
