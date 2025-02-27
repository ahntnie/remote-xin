// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStory _$UserStoryFromJson(Map<String, dynamic> json) => UserStory(
      userId: json['user_id'] as int,
      stories: (json['stories'] as List<dynamic>)
          .map((e) => Story.fromJson(e as Map<String, dynamic>))
          .toList(),
      avatar: json['avatar'] as String?,
      name: json['name'] as String?,
      nickname: json['nickname'] as String?,
    );

Map<String, dynamic> _$UserStoryToJson(UserStory instance) => <String, dynamic>{
      'user_id': instance.userId,
      'avatar': instance.avatar,
      'name': instance.name,
      'nickname': instance.nickname,
      'stories': instance.stories.map((e) => e.toJson()).toList(),
    };
