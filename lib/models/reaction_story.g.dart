// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReactionStory _$ReactionStoryFromJson(Map<String, dynamic> json) =>
    ReactionStory(
      userId: json['user_id'] as int,
      type: json['type'] as String,
    );

Map<String, dynamic> _$ReactionStoryToJson(ReactionStory instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'type': instance.type,
    };
