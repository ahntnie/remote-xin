import 'package:freezed_annotation/freezed_annotation.dart';

import 'all.dart';

part 'jump_to_message.g.dart';

@JsonSerializable()
class JumpToMessage {
  List<Message>? messages;
  int? limit;
  int? skip;
  @JsonKey(name: 'pageNumber')
  int? pageNumber;

  JumpToMessage({
    this.messages,
    this.limit,
    this.skip,
    this.pageNumber,
  });

  factory JumpToMessage.fromJson(Map<String, dynamic> json) {
    return _$JumpToMessageFromJson(json);
  }

  Map<String, dynamic> toJson() => _$JumpToMessageToJson(this);

  static List<JumpToMessage> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => JumpToMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
