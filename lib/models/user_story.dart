import 'package:freezed_annotation/freezed_annotation.dart';

import 'story.dart';

part 'user_story.g.dart';

@JsonSerializable()
class UserStory {
  final int userId;
  final String? avatar;
  final String? name;
  final String? nickname;
  final List<Story> stories;

  UserStory({
    required this.userId,
    required this.stories,
    this.avatar,
    this.name,
    this.nickname,
  });

  factory UserStory.fromJson(Map<String, dynamic> json) {
    return UserStory(
      userId: json['user_id'],
      avatar: json['avatar'],
      name: json['name'],
      nickname: json['nickname'],
      stories: List<Story>.from(json['stories'].map((x) => Story.fromJson(x))),
    );
  }
}
