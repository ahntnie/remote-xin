// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Story _$StoryFromJson(Map<String, dynamic> json) => Story(
      storyId: json['story_id'] as int,
      storyType: json['story_type'] as String,
      status: json['status'] as String,
      timeEnd: json['time_end'] as String,
      reactions: (json['reactions'] as List<dynamic>)
          .map((e) => ReactionStory.fromJson(e as Map<String, dynamic>))
          .toList(),
      colorCode: json['color_code'] as String?,
      typeMedia: json['type_media'] as String?,
      urlMedia: json['url_media'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$StoryToJson(Story instance) => <String, dynamic>{
      'story_id': instance.storyId,
      'story_type': instance.storyType,
      'color_code': instance.colorCode,
      'type_media': instance.typeMedia,
      'url_media': instance.urlMedia,
      'content': instance.content,
      'status': instance.status,
      'time_end': instance.timeEnd,
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    };
