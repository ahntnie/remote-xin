// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_or_remove_user_by_socket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddOrRemoveUserBySocket _$AddOrRemoveUserBySocketFromJson(
        Map<String, dynamic> json) =>
    AddOrRemoveUserBySocket(
      roomId: json['roomId'] as String,
      addedMembers: (json['addedMembers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      removedMembers: (json['removedMembers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AddOrRemoveUserBySocketToJson(
        AddOrRemoveUserBySocket instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'addedMembers': instance.addedMembers,
      'removedMembers': instance.removedMembers,
    };
