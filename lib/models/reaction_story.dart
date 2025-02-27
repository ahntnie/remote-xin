import 'package:freezed_annotation/freezed_annotation.dart';

part 'reaction_story.g.dart';

@JsonSerializable()
class ReactionStory {
  final int userId;
  final String type;

  ReactionStory({
    required this.userId,
    required this.type,
  });

  factory ReactionStory.fromJson(Map<String, dynamic> json) {
    final story = _$ReactionStoryFromJson(json);

    return story;
  }

  Map<String, dynamic> toJson() => _$ReactionStoryToJson(this);
}
