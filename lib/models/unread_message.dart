import 'package:json_annotation/json_annotation.dart';

part 'unread_message.g.dart';

@JsonSerializable()
class UnreadMessage {
  @JsonKey(name: 'roomId')
  String roomId;
  @JsonKey(name: 'unread')
  int unreadCount;

  UnreadMessage({required this.roomId, required this.unreadCount});

  factory UnreadMessage.fromJson(Map<String, dynamic> json) {
    return _$UnreadMessageFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UnreadMessageToJson(this);
}
