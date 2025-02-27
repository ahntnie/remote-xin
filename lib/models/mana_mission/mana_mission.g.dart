// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mana_mission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManaMission _$ManaMissionFromJson(Map<String, dynamic> json) => ManaMission(
      id: json['id'] as String?,
      status: json['status'] as int?,
      comment: json['comment'] as String?,
      userId: json['userId'] as int?,
      email: json['email'] as String?,
      expired: json['expired'] as int?,
      missionId: json['missionId'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
      userMission: json['userMission'] == null
          ? null
          : UserMission.fromJson(json['userMission']),
      progress: json['progress'] == null
          ? null
          : MissionProgress.fromJson(json['progress']),
    );

Map<String, dynamic> _$ManaMissionToJson(ManaMission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'comment': instance.comment,
      'userId': instance.userId,
      'email': instance.email,
      'expired': instance.expired,
      'missionId': instance.missionId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.v,
      'userMission': instance.userMission?.toJson(),
      'progress': instance.progress?.toJson(),
    };
