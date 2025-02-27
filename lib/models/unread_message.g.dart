// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnreadMessage _$UnreadMessageFromJson(Map<String, dynamic> json) =>
    UnreadMessage(
      roomId: json['roomId'] as String,
      unreadCount: json['unread'] as int,
    );

Map<String, dynamic> _$UnreadMessageToJson(UnreadMessage instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'unread': instance.unreadCount,
    };
