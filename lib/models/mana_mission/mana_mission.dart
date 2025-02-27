import 'package:json_annotation/json_annotation.dart';

import 'mission_progress.dart';

part 'mana_mission.g.dart';

@JsonSerializable()
class ManaMission {
  ManaMission({
    this.id,
    this.status,
    this.comment,
    this.userId,
    this.email,
    this.expired,
    this.missionId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.userMission,
    this.progress,
  });

  String? id;
  int? status;
  String? comment;
  @JsonKey(name: 'userId')
  int? userId;
  String? email;
  int? expired;
  @JsonKey(name: 'missionId')
  int? missionId;
  @JsonKey(name: 'createdAt')
  String? createdAt;
  @JsonKey(name: 'updatedAt')
  String? updatedAt;
  @JsonKey(name: '__v')
  int? v;
  @JsonKey(name: 'userMission')
  UserMission? userMission;
  @JsonKey(name: 'progress')
  MissionProgress? progress;

  bool isComplete() {
    return status == 2;
  }

  factory ManaMission.fromJson(Map<String, dynamic> json) {
    return _$ManaMissionFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ManaMissionToJson(this);

  static List<ManaMission> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => ManaMission.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class UserMission {
  UserMission({
    this.id,
    this.active,
    this.link,
    this.missionId,
    this.content,
    this.title,
    this.reward,
    this.type,
    this.quantity,
    this.friend,
    this.v,
    this.createdAt,
    this.updatedAt,
    this.image,
  });

  UserMission.fromJson(dynamic json) {
    id = json['_id'];
    active = json['active'];
    link = json['link'];
    missionId = json['missionId'];
    content = json['content'];
    title = json['title'];
    reward = json['reward'];
    type = json['type'];
    quantity = json['quantity'];
    friend = json['friend'];
    v = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    image = json['image'];
    languages = json['language'];
  }

  String? id;
  bool? active;
  String? link;
  num? missionId;
  String? content;
  String? title;
  num? reward;
  String? type;
  num? quantity;
  num? friend;
  num? v;
  String? createdAt;
  String? updatedAt;
  String? image;
  Map<String, dynamic>? languages;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['active'] = active;
    map['link'] = link;
    map['missionId'] = missionId;
    map['content'] = content;
    map['title'] = title;
    map['reward'] = reward;
    map['type'] = type;
    map['quantity'] = quantity;
    map['friend'] = friend;
    map['__v'] = v;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['language'] = languages;

    return map;
  }
}
